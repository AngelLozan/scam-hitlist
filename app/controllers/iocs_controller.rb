require "mail"
require "uri"
require "net/http"
require 'date'
# require 'puppeteer'
require 'json'
require "aws-sdk-s3"

class IocsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[new simple_create]
  skip_after_action :verify_authorized, only: %i[reported follow_up tb_reported watchlist]
  before_action :set_ioc, only: %i[show screenshot edit update ca destroy]
  helper_method :sort_column, :sort_direction

  # GET /iocs or /iocs.json
  def index
    @iocs = policy_scope(Ioc)
    @iocs = @iocs.where.not(status: :official_url).order("#{sort_column} #{sort_direction}").page params[:page]
    @hosts = policy_scope(Host)
    @forms = policy_scope(Form)
    # @hosts = Host.all
    # @forms = Form.all

    return unless params[:query].present?

    sql_subquery = <<~SQL
      iocs.url ILIKE :query
      OR iocs.host ILIKE :query
      OR iocs.form ILIKE :query
    SQL
    @iocs = @iocs.where(sql_subquery, query: "%#{params[:query]}%").page params[:page]
  end

  def reported
    @iocs = policy_scope(Ioc)
    @iocs = @iocs.where(status: 1).order("#{sort_column} #{sort_direction}").page params[:page]
    @hosts = policy_scope(Host)
    @forms = policy_scope(Form)
    # @hosts = Host.all
    # @forms = Form.all

    return unless params[:query].present?

    sql_subquery = <<~SQL
      iocs.url ILIKE :query
      OR iocs.host ILIKE :query
      OR iocs.form ILIKE :query
    SQL
    @iocs = @iocs.where(sql_subquery, query: "%#{params[:query]}%").page params[:page]
  end

  def follow_up
    @iocs = policy_scope(Ioc)
    @iocs = @iocs.follow_up_needed.order("#{sort_column} #{sort_direction}").page params[:page]
    @hosts = policy_scope(Host)
    @forms = policy_scope(Form)
    # @hosts = Host.all
    # @forms = Form.all

    return unless params[:query].present?

    sql_subquery = <<~SQL
      iocs.url ILIKE :query
      OR iocs.host ILIKE :query
      OR iocs.form ILIKE :query
    SQL
    @iocs = @iocs.where(sql_subquery, query: "%#{params[:query]}%").page params[:page]
  end

  def tb_reported
    @iocs = policy_scope(Ioc)
    @iocs = @iocs.tb_reported.order("#{sort_column} #{sort_direction}").page params[:page]
  end

  def watchlist
    @iocs = policy_scope(Ioc)
    @iocs = @iocs.watchlist.order("#{sort_column} #{sort_direction}").page params[:page]
    @hosts = policy_scope(Host)
    @forms = policy_scope(Form)
    # @hosts = Host.all
    # @forms = Form.all

    return unless params[:query].present?

    sql_subquery = <<~SQL
      iocs.url ILIKE :query
      OR iocs.host ILIKE :query
      OR iocs.form ILIKE :query
    SQL
    @iocs = @iocs.where(sql_subquery, query: "%#{params[:query]}%").page params[:page]
  end

  def show
    authorize @ioc

    if params[:screenshot_url]
      begin
        url = ActionController::Base.helpers.sanitize(params[:screenshot_url])
        api_token = ENV['BROWSERLESS_TOKEN']
        ws_url = "wss://chrome.browserless.io?token=#{api_token}"

        Puppeteer.connect(browser_ws_endpoint: ws_url) do |browser|
          page = browser.pages.first || browser.new_page
          page.goto(url)
          @image = page.screenshot()
        end

      rescue StandardError => e
        # flash[:alert] = "An error occurred while taking the screenshot: #{e.message}"
        @screenshot_error = "An error occurred while capturing the screenshot: #{e.message}"
      end
    end

    # @dev To account for legacy data. Needs cleaning to avoid so many conditions.
    if (@ioc.host.nil? && @ioc.form.nil?) || (@ioc.host == "null" && @ioc.form == "null")
      @form = { "name" => "none", "url" => "null" }
      @host = { "name" => "none", "email" => "null" }
    elsif @ioc.host.nil? || @ioc.host == "null"
      @host = { "name" => "none", "email" => "null" }
      if check_number?(@ioc.form)
        @form = Form.find(@ioc.form)
      else
        @form = Form.find_by(name: @ioc.form)
      end
    elsif @ioc.form.nil? || @ioc.form == "null"
      @form = { "name" => "none", "url" => "null" }
      if check_number?(@ioc.host)
        @host = Host.find(@ioc.host.to_i)
      else
        @host = Host.find_by(name: @ioc.host)
      end
    else
      if check_number?(@ioc.form)
        @form = Form.find(@ioc.form.to_i)
      else
        @form = Form.find_by(name: @ioc.form)
      end

      if check_number?(@ioc.host)
        @host = Host.find(@ioc.host.to_i)
      else
        @host = Host.find_by(name: @ioc.host)
      end
    end
  end

  # GET /iocs/new
  def new
    @ioc = Ioc.new
    authorize @ioc
    @hosts = policy_scope(Host)
    @forms = policy_scope(Form)
    # @forms = Form.all
    # @hosts = Host.all
  end

  # GET /iocs/1/edit
  def edit
    authorize @ioc
    @hosts = policy_scope(Host)
    @forms = policy_scope(Form)
    # @forms = Form.all
    # @hosts = Host.all
  end

  def presigned
    @ioc = Ioc.find(1) # Dummy Ioc needed for pundit. Not modified
    authorize @ioc
    bucket_name = ENV['BUCKET']
    region = "eu-north-1"
    Aws.config.update(region: region)

    bucket = Aws::S3::Bucket.new(bucket_name)
    object_key = params[:fileName]

    url = bucket.object(object_key).presigned_url(:put)
    puts "Created presigned URL: #{url}"
    render json: { presigned_url: url }
    rescue Aws::Errors::ServiceError => e
      puts "Couldn't create presigned URL for #{bucket.name}:#{object_key}. Here's why: #{e.message}"
      render json: { error: "Failed to generate presigned URL" }, status: :unprocessable_entity
  end

  def download_presigned
    @ioc = Ioc.find(1) # Dummy Ioc needed for pundit. Not modified.
    authorize @ioc
    key = params[:key]
    signer = Aws::S3::Presigner.new
    url = signer.presigned_url(:get_object,
                 bucket: ENV['BUCKET'],
                 key: key,
                 expires_in: 7.days.to_i,
                 response_content_disposition: "attachment"
                 )
    puts " >>>>>>>> Created download url: #{url} <<<<<<<<<<<"
    render json: { download_url: url }
  end
  

  def create
    @ioc = Ioc.new(ioc_params)
    authorize @ioc
    @iocs = policy_scope(Ioc)
    @iocs = @iocs
    @ioc.url = sanitize_url(@ioc.url)
    @ioc.comments = sanitize_comments(@ioc.comments)

    all_urls = @iocs.pluck(:url)
    new_url = @ioc.url.present? ? "http://#{@ioc.url}" : ""

    respond_to do |format|
      if @ioc.url.present? && all_urls.any? { |u| u.include? new_url }
        # format.html do
        #   redirect_to iocs_url, status: :unprocessable_entity, alert_success: "This has already been added 👍"
        # end
        format.json { render json: { errors: ["This has already been added 👍"] }, status: :unprocessable_entity, alert_success: "This has already been added 👍" }
      elsif @ioc.save
        format.json { render json: { ioc: @ioc, show_url: ioc_url(@ioc), alert_success: "A record was successfully created ✅" }, status: :created }
      else
        format.json { render json: { errors: @ioc.errors.full_messages, alert_warning: "Something is wrong/missing (URL?) 🤔" }, status: :unprocessable_entity }
      end
    end
  end


  def simple_create
    @ioc = Ioc.new(ioc_simple_params)
    authorize @ioc
    @ioc.url = sanitize_url(@ioc.url)
    @ioc.comments = sanitize_comments(@ioc.comments)

    all_urls = Ioc.pluck(:url)
    official_urls = Ioc.where(status: 3).pluck(:url)
    new_url = @ioc.protocol_to_url

    respond_to do |format|
      if @ioc.url.present? && official_urls.any? { |u| u.include? new_url }
        format.html do
          redirect_to root_path, status: :unprocessable_entity,
                                 alert_primary: "This is owned by Exodus, please check with the team 😎"
        end
        format.json { render json: @ioc.errors, status: :unprocessable_entity }
        puts "\n OFFICIAL \n"
      elsif @ioc.url.present? && all_urls.any? { |u| u.include? new_url }
        format.html do
          redirect_to root_path, status: :unprocessable_entity, alert_success: "This has already been reported 👍"
        end
        format.json { render json: @ioc.errors, status: :unprocessable_entity }
        puts "\n JA \n >>>>>#{new_url}<<<< \n"
      elsif verify_recaptcha(model: @ioc) && @ioc.save
        format.html do
          redirect_to root_path, alert_success: "A record was successfully created, thanks! We'll review this shortly ✅"
        end
        format.json { render :show, status: :created, location: @ioc }
      elsif !@ioc.url.present?
        format.html { redirect_to root_path, status: :unprocessable_entity, alert_warning: "First field is required 👀" }
        format.json { render json: @ioc.errors, status: :unprocessable_entity }
      elsif !verify_recaptcha(model: @ioc)
        format.html do
          redirect_to root_path, status: :unprocessable_entity, alert_danger: "Please complete recaptcha 🤖"
        end
        format.json { render json: object.errors, status: :unprocessable_entity }
        puts "\n CAPTCHA \n >>>>>#{new_url}<<<< \n"
      else
        format.html { redirect_to root_path, status: :unprocessable_entity, alert_warning: "Something is missing 🤔" }
        format.json { render json: @ioc.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @hosts = policy_scope(Host)
    @forms = policy_scope(Form)
    authorize @ioc
    # @forms = Form.all
    # @hosts = Host.all
    @ioc.url = sanitize_url(@ioc.url)
    @ioc.comments = sanitize_comments(@ioc.comments)

    respond_to do |format|
      if @ioc.update(ioc_params)
        format.html { redirect_to ioc_url(@ioc), alert_success: "The record was successfully updated." }
        format.json { render json: { zf_status: 'submitted_zf' }, status: :ok, location: @ioc }
      else
        format.html { render :edit, status: :unprocessable_entity, alert_warning: "Something is missing" }
        format.json { render json: @ioc.errors.full_messages, status: :unprocessable_entity }
      end
    end
  end

  def ca
    authorize @ioc
    request_body = [
      {
        addresses: [
          {
            domain: @ioc.url.to_s,
          },
        ],
        agreedToBeContactedData: {
          agreed: true,
        },
        scamCategory: "PHISHING",
        description: "Phishing site",
      },
    ]

    url = URI("https://api.chainabuse.com/v0/reports/batch")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(url)
    request["accept"] = "application/json"
    request["content-type"] = "application/json"
    request["authorization"] = ENV.fetch("CA_TOKEN", nil).to_s
    request.body = JSON.dump(request_body)

    response = http.request(request)
    puts response.read_body

    render json: JSON.parse(response.body), status: response.code
  end


  def destroy
    @ioc.destroy
    authorize @ioc

    respond_to do |format|
      format.html { redirect_to iocs_url, alert_success: "The record was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  def check_number?(str)
    Integer(str)
  rescue StandardError
    false
  end

  def set_ioc
    @ioc = Ioc.find(params[:id])
  end

  def ioc_params
    params.require(:ioc).permit(:status, :url, :removed_date, :report_method_one, :report_method_two, :form, :host,
                                :follow_up_date, :follow_up_count, :comments, :file_url, :zf_status, :ca_status, :pt_status, :gg_status)
  end

  def sanitize_url(url)
    ActionController::Base.helpers.sanitize(url)
  end

  def sanitize_comments(comments)
    ActionController::Base.helpers.sanitize(comments)
  end

  def ioc_simple_params
    params.require(:ioc).permit(:url, :comments, :file)
  end

  def sort_column
    Ioc.column_names.include?(params[:sort]) ? params[:sort] : "url" # Defaults to url column
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end

  # def valid_file_type?(file)
  #   allowed_types = %w[image/jpeg image/png text/plain message/rfc822]
  #   allowed_types.include?(file.content_type)
  # end

  # def valid_file_size?(file)
  #   max_file_size_in_bytes = 5 * 1024 * 1024 # 5 MB
  #   file.size <= max_file_size_in_bytes && file.size > 0
  # end

  # def virus_total(file_upload)
  #   api_key = ENV['VIRUS_TOTAL']
  #   vtscan = VirustotalAPI::File.upload(file_upload, api_key)
  #   upload_id = vtscan.id
  #   puts "========================================="
  #   puts "===========>> #{vtscan.id} <=="
  #   puts "========================================="
  #   return upload_id
  # end

  # def enqueue_scan(file_upload, ioc_id)
  #   id = virus_total(file_upload)
  #   CheckScan.set(wait: 20.minutes).perform_later(id, ioc_id)
  # end

  # def virus_total?(file_upload)
  #   # file = VirusTotal::File.new(upload, ENV['VIRUS_TOTAL'])

  #   api_key = "#{ENV['VIRUS_TOTAL']}"
  #   vtscan = VirustotalAPI::File.upload(file_upload, api_key)
  #   upload_id = vtscan.id
  #   puts "========================================="
  #   puts "===========>> #{vtscan.id} <=="
  #   puts "========================================="

  #   # @dev Get the results after short period of time. 
  #   # resource = file.scan.response["scan_id"]
  #   url = URI("https://www.virustotal.com/vtapi/v2/file/report?apikey=#{ENV['VIRUS_TOTAL']}&resource=#{upload_id}&allinfo=true")

  #   http = Net::HTTP.new(url.host, url.port)
  #   http.use_ssl = true

  #   request = Net::HTTP::Get.new(url)

  #   response = http.request(request)
  #   parsed_response = JSON.parse(response.read_body)
  #   positives_count = parsed_response["positives"]
  #   puts "Positives count: #{positives_count}"

  #   if positives_count > 0
  #     return false
  #   else
  #     return true
  #   end
  # end

end
