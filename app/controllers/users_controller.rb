class UsersController < ApplicationController
  before_action :set_user, only: %i[show destroy]
  skip_after_action :verify_authorized, only: :index

  def index
    @users = policy_scope(User)
    @users = @users
  end

  def show
    authorize @user
  end

  def new
    @user = User.new
    authorize @user
  end

  def destroy
    authorize @user
    @user.destroy

    respond_to do |format|
      format.html { redirect_to root_path, notice: "User was successfully destroyed." }
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end


end
