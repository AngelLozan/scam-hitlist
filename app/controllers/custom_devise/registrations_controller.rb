class CustomDevise::RegistrationsController < Devise::RegistrationsController
  def create
    @email = params[:user][:email]
    @users = User.all
    
    if @email == 'scott@exodus.io' || @email == 'dean@exodus.io'
    # if @users.include?(@email)
      super # Call the default create method from Devise
    else
      flash[:alert] = "Login is restricted to only the SecOps team 😎."
      redirect_to root_path
    end
  end
end