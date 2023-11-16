class FormsController < ApplicationController
  before_action :set_form, only: %i[show edit update destroy]

  def index
    @forms = policy_scope(Form)
    # @forms = Form.all
  end


  def show
    authorize @form
  end


  def new
    authorize @form
    @form = Form.new
  end


  def edit
    authorize @form
  end


  def create
    authorize @form
    @form = Form.new(form_params)

    respond_to do |format|
      if @form.save
        format.html { redirect_to form_url(@form), notice: "Form was successfully created." }
        format.json { render :show, status: :created, location: @form }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @form.errors, status: :unprocessable_entity }
      end
    end
  end


  def update
    authorize @form
    respond_to do |format|
      if @form.update(form_params)
        format.html { redirect_to form_url(@form), notice: "Form was successfully updated." }
        format.json { render :show, status: :ok, location: @form }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @form.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize @form
    @form.destroy

    respond_to do |format|
      format.html { redirect_to forms_url, notice: "Form was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  def set_form
    @form = Form.find(params[:id])
  end

  def form_params
    params.require(:form).permit(:name, :url)
  end
end
