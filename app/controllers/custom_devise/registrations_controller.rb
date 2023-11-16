class CustomDevise::RegistrationsController < Devise::RegistrationsController
  before_action :set_user, only: :destroy
  before_action :authenticate_user!, :redirect_unless_brand_protector,  only: [:new, :create]
  skip_before_action :require_no_authentication

  # def create
  #    @user = User.new(user_params)
  #    authorize @user
  #   # @users = policy_scope(User)
  #   # @email = params[:user][:email]
  #   # @users = @users

  #   # @users.find_by(email: @email) &&
  #   if current_user.is_brand_protector? && @user.save
  #   # if @email == 'scott@exodus.io' || @email == 'dean@exodus.io'
  #   # if @users.include?(@email)
  #     super # Call the default create method from Devise
  #   else
  #     flash[:alert] = "Login is restricted to only the SecOps team 😎."
  #     redirect_to root_path
  #   end
  # end

  def create
    @user = User.new(user_params)
    authorize @user

    respond_to do |format|
      if current_user.is_brand_protector? && @user.save
        # super
        format.html { redirect_to user_url(@user), notice: "User was successfully created." }
      else
        format.html { render :new, status: :unprocessable_entity, notice: "Something went wrong, try again please 🤔" }
      end
    end
  end

  def destroy
    authorize @user
    @user.destroy

    respond_to do |format|
      format.html { redirect_to users_path, notice: "User was successfully destroyed." }
    end
  end


  private

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end

  def set_user
    @user = User.find(params[:id])
  end

    def redirect_unless_brand_protector
      if !current_user
        flash[:error] = "Login is restricted to only the SecOps team 😎."
        redirect_to root_path
      else
        unless current_user.is_brand_protector?
          flash[:error] = "Login is restricted to only the SecOps team 😎."
          redirect_to root_path
        end
      end
  end

end