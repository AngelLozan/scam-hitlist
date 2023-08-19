require "mail"
require "uri"
require "net/http"
require 'date'
require 'puppeteer'

class IocsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[new simple_create]
  before_action :set_ioc, only: %i[show screenshot edit update ca destroy]
  helper_method :sort_column, :sort_direction

  # GET /iocs or /iocs.json
  def index
    @iocs = Ioc.where.not(status: :official_url).order("#{sort_column} #{sort_direction}").page params[:page]
    @hosts = Host.all
    @forms = Form.all

    return unless params[:query].present?

    sql_subquery = <<~SQL
      iocs.url ILIKE :query
      OR iocs.host ILIKE :query
      OR iocs.form ILIKE :query
    SQL
    @iocs = @iocs.where(sql_subquery, query: "%#{params[:query]}%").page params[:page]
  end

  def reported
    @iocs = Ioc.where(status: 1).order("#{sort_column} #{sort_direction}").page params[:page]
    @hosts = Host.all
    @forms = Form.all

    return unless params[:query].present?

    sql_subquery = <<~SQL
      iocs.url ILIKE :query
      OR iocs.host ILIKE :query
      OR iocs.form ILIKE :query
    SQL
    @iocs = @iocs.where(sql_subquery, query: "%#{params[:query]}%").page params[:page]
  end

  def follow_up
    @iocs = Ioc.follow_up_needed.order("#{sort_column} #{sort_direction}").page params[:page]
    @hosts = Host.all
    @forms = Form.all

    return unless params[:query].present?

    sql_subquery = <<~SQL
      iocs.url ILIKE :query
      OR iocs.host ILIKE :query
      OR iocs.form ILIKE :query
    SQL
    @iocs = @iocs.where(sql_subquery, query: "%#{params[:query]}%").page params[:page]
  end

  def tb_reported
    @iocs = Ioc.tb_reported.order("#{sort_column} #{sort_direction}").page params[:page]
  end

  def watchlist
    @iocs = Ioc.watchlist.order("#{sort_column} #{sort_direction}").page params[:page]
    @hosts = Host.all
    @forms = Form.all

    return unless params[:query].present?

    sql_subquery = <<~SQL
      iocs.url ILIKE :query
      OR iocs.host ILIKE :query
      OR iocs.form ILIKE :query
    SQL
    @iocs = @iocs.where(sql_subquery, query: "%#{params[:query]}%").page params[:page]
  end

  def show
    # @dev For screenshoting from within the app.
    if params[:screenshot_url]
      url = ActionController::Base.helpers.sanitize(params[:screenshot_url])
      api_token = ENV['BROWSERLESS_TOKEN']
      ws_url = "wss://chrome.browserless.io?token=#{api_token}"

      Puppeteer.connect(browser_ws_endpoint: ws_url) do |browser|
        page = browser.pages.first || browser.new_page
        page.goto(url)
        @image = page.screenshot()
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
    @forms = Form.all
    @hosts = Host.all
  end

  # GET /iocs/1/edit
  def edit
    @forms = Form.all
    @hosts = Host.all
  end

  # POST /iocs or /iocs.json
  def create
    @ioc = Ioc.new(ioc_params)
    @ioc.url = sanitize_url(@ioc.url)
    @ioc.comments = sanitize_comments(@ioc.comments)

    if params[:ioc][:file].present?
      uploaded_file = params[:ioc][:file]
      if valid_file_type?(uploaded_file) && valid_file_size?(uploaded_file)
        if (uploaded_file.content_type == "message/rfc822")
          eml_content = uploaded_file.read
          mail = Mail.new(eml_content)
          txt_content = mail.body.decoded
          txt_file = Tempfile.new(["converted", ".txt"], encoding: "ascii-8bit")
          txt_file.write(txt_content)
          txt_file.rewind

          txt_uploaded_file = ActionDispatch::Http::UploadedFile.new(
            tempfile: txt_file,
            filename: "#{uploaded_file.original_filename.chomp(".eml")}.txt",
            type: "text/plain",
          )
          uploaded_file = txt_uploaded_file
        end

        file_extension = File.extname(uploaded_file.original_filename)
        random_filename = SecureRandom.hex + file_extension
        @ioc.file.attach(io: uploaded_file, filename: random_filename)
      else
        respond_to do |format|
          format.html do
            redirect_to root_path, status: :unprocessable_entity, alert_warning: "Invalid file type or size. Please choose a valid file."
          end
          format.json { render json: { error: "Invalid file type or size." }, status: :unprocessable_entity }
        end
        return
      end
    # else
    #   respond_to do |format|
    #     format.html { redirect_to root_path, status: :unprocessable_entity, alert_warning: "Failed to upload the file. Please try again with a valid file." }
    #     format.json { render json: { error: "Failed to upload the file. Please try again with a valid file." }, status: :unprocessable_entity }
    #   end
    end


    all_urls = Ioc.pluck(:url)
    new_url = @ioc.url.present? ? "http://#{@ioc.url}" : ""

    respond_to do |format|
      if @ioc.url.present? && all_urls.any? { |u| u.include? new_url }
        format.html do
          redirect_to root_path, status: :unprocessable_entity, alert_success: "This has already been added 👍"
        end
        format.json { render json: @ioc.errors, status: :unprocessable_entity }
      elsif @ioc.save
        format.html { redirect_to ioc_url(@ioc), alert_success: "A record was successfully created ✅" }
        format.json { render :show, status: :created, location: @ioc }
      else
        format.html { render :new, status: :unprocessable_entity, alert_warning: "Something is wrong 🤔" }
        format.json { render json: @ioc.errors, status: :unprocessable_entity }
      end
    end
  end

  def simple_create
    @ioc = Ioc.new(ioc_simple_params)
    @ioc.url = sanitize_url(@ioc.url)
    @ioc.comments = sanitize_comments(@ioc.comments)

    if params[:ioc][:file].present?
      uploaded_file = params[:ioc][:file]
      if valid_file_type?(uploaded_file) && valid_file_size?(uploaded_file)
        if (uploaded_file.content_type == "message/rfc822")
          eml_content = uploaded_file.read
          mail = Mail.new(eml_content)
          txt_content = mail.body.decoded
          txt_file = Tempfile.new(["converted", ".txt"], encoding: "ascii-8bit")
          txt_file.write(txt_content)
          txt_file.rewind

          txt_uploaded_file = ActionDispatch::Http::UploadedFile.new(
            tempfile: txt_file,
            filename: "#{uploaded_file.original_filename.chomp(".eml")}.txt",
            type: "text/plain",
          )
          uploaded_file = txt_uploaded_file
        end

        file_extension = File.extname(uploaded_file.original_filename)
        random_filename = SecureRandom.hex + file_extension
        @ioc.file.attach(io: uploaded_file, filename: random_filename)
      else
        respond_to do |format|
          format.html do
            redirect_to root_path, status: :unprocessable_entity, alert_warning: "Invalid file type or size. Please choose a valid file."
          end
          format.json { render json: { error: "Invalid file type or size." }, status: :unprocessable_entity }
        end
        return
      end
    end

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
    @forms = Form.all
    @hosts = Host.all
    @ioc.url = sanitize_url(@ioc.url)
    @ioc.comments = sanitize_comments(@ioc.comments)

    if params[:ioc][:file].present?
      uploaded_file = params[:ioc][:file]
      if valid_file_type?(uploaded_file) && valid_file_size?(uploaded_file)
        if (uploaded_file.content_type == "message/rfc822")
          eml_content = uploaded_file.read
          mail = Mail.new(eml_content)
          txt_content = mail.body.decoded
          txt_file = Tempfile.new(["converted", ".txt"], encoding: "ascii-8bit")
          txt_file.write(txt_content)
          txt_file.rewind

          txt_uploaded_file = ActionDispatch::Http::UploadedFile.new(
            tempfile: txt_file,
            filename: "#{uploaded_file.original_filename.chomp(".eml")}.txt",
            type: "text/plain",
          )
          uploaded_file = txt_uploaded_file
        end

        file_extension = File.extname(uploaded_file.original_filename)
        random_filename = SecureRandom.hex + file_extension
        @ioc.file.attach(io: uploaded_file, filename: random_filename)
      else
        respond_to do |format|
          format.html do
            redirect_to ioc_path, status: :unprocessable_entity, alert_warning: "Invalid file type or size. Please choose a valid file."
          end
          format.json { render json: { error: "Invalid file type or size." }, status: :unprocessable_entity }
        end
        return
      end
    end

    respond_to do |format|
      if @ioc.update(ioc_params)
        format.html { redirect_to ioc_url(@ioc), alert_success: "The record was successfully updated." }
        format.json { render :show, status: :ok, location: @ioc }
      else
        format.html { render :edit, status: :unprocessable_entity, alert_warning: "Something is missing" }
        format.json { render json: @ioc.errors.full_messages, status: :unprocessable_entity }
      end
    end
  end

  def ca
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

  # Use callbacks to share common setup or constraints between actions.
  def set_ioc
    @ioc = Ioc.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def ioc_params
    params.require(:ioc).permit(:status, :url, :removed_date, :report_method_one, :report_method_two, :form, :host,
                                :follow_up_date, :follow_up_count, :comments, :file, :zf_status, :ca_status, :pt_status, :gg_status)
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

  def valid_file_type?(file)
    allowed_types = %w[image/jpeg image/png application/pdf text/plain message/rfc822]
    allowed_types.include?(file.content_type)
  end

  def valid_file_size?(file)
    max_file_size_in_bytes = 5 * 1024 * 1024 # 5 MB
    file.size <= max_file_size_in_bytes && file.size > 0
  end
end
