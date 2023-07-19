require "mail"

class IocsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[new simple_create]
  before_action :set_ioc, only: %i[show edit update destroy]
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

  # GET /iocs/1 or /iocs/1.json
  def show

    if @ioc.host.nil? && @ioc.form.nil? || @ioc.host == "null" && @ioc.form == "null"
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
    if params[:ioc][:file].present?
      if params[:ioc][:file].content_type == "message/rfc822"
        eml_content = params[:ioc][:file].read
        mail = Mail.new(eml_content)
        txt_content = mail.body.decoded
        txt_file = Tempfile.new(["converted", ".txt"], encoding: "ascii-8bit")
        txt_file.write(txt_content)
        txt_file.rewind

        txt_uploaded_file = ActionDispatch::Http::UploadedFile.new(
          tempfile: txt_file,
          filename: params[:ioc][:file].original_filename.chomp(".eml") + ".txt",
          type: "text/plain",
        )
        params[:ioc][:file] = txt_uploaded_file
      end
    end

    @ioc = Ioc.new(ioc_params)

    respond_to do |format|
      if @ioc.save
        format.html { redirect_to ioc_url(@ioc), notice: "Ioc was successfully created." }
        format.json { render :show, status: :created, location: @ioc }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @ioc.errors, status: :unprocessable_entity }
      end
    end
  end

  def simple_create
    if params[:ioc][:file].present?
      if params[:ioc][:file].content_type == "message/rfc822"
        eml_content = params[:ioc][:file].read
        mail = Mail.new(eml_content)
        txt_content = mail.body.decoded
        txt_file = Tempfile.new(["converted", ".txt"], encoding: "ascii-8bit")
        txt_file.write(txt_content)
        txt_file.rewind

        txt_uploaded_file = ActionDispatch::Http::UploadedFile.new(
          tempfile: txt_file,
          filename: params[:ioc][:file].original_filename.chomp(".eml") + ".txt",
          type: "text/plain",
        )
        params[:ioc][:file] = txt_uploaded_file
      end
    end

    @ioc = Ioc.new(ioc_simple_params)

    respond_to do |format|
      if @ioc.save
        format.html { redirect_to root_path, notice: "Ioc was successfully created." }
        format.json { render :show, status: :created, location: @ioc }
      else
        format.html { redirect_to root_path, status: :unprocessable_entity, notice: "Already reported" }
        format.json { render json: @ioc.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /iocs/1 or /iocs/1.json
  def update
    @forms = Form.all
    @hosts = Host.all

    if params[:ioc][:file].present?
      # Check if it's an .eml file and perform the conversion if needed
      if params[:ioc][:file].content_type == "message/rfc822"
        # Read the contents of the .eml file
        eml_content = params[:ioc][:file].read

        # Convert the .eml content to .txt format using the mail gem
        mail = Mail.new(eml_content)
        txt_content = mail.body.decoded

        # Create a Tempfile with the .txt content
        txt_file = Tempfile.new(["converted", ".txt"], encoding: "ascii-8bit")
        txt_file.write(txt_content)
        txt_file.rewind

        # Create a new ActionDispatch::Http::UploadedFile object with the Tempfile
        txt_uploaded_file = ActionDispatch::Http::UploadedFile.new(
          tempfile: txt_file,
          filename: params[:ioc][:file].original_filename.chomp(".eml") + ".txt",
          type: "text/plain",
        )

        # Replace the original .eml file in the params with the new .txt file
        params[:ioc][:file] = txt_uploaded_file
      end
    end

    respond_to do |format|
      if @ioc.update(ioc_params)
        format.html { redirect_to ioc_url(@ioc), notice: "Ioc was successfully updated." }
        format.json { render :show, status: :ok, location: @ioc }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @ioc.errors.full_messages, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /iocs/1 or /iocs/1.json
  def destroy
    @ioc.destroy

    respond_to do |format|
      format.html { redirect_to iocs_url, notice: "Ioc was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  def check_number?(str)
    Integer(str) rescue false
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_ioc
    @ioc = Ioc.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def ioc_params
    params.require(:ioc).permit(:status, :url, :removed_date, :report_method_one, :report_method_two, :form, :host,
                                :follow_up_date, :follow_up_count, :comments, :file, :zf_status, :ca_status, :pt_status, :gg_status )
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
end
