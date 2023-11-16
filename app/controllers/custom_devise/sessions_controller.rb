class CustomDevise::SessionsController < Devise::SessionsController
  def create
    @user = current_user
    
    if @user.email == 'scott@exodus.io' || @user.email == 'dean@exodus.io'
      super # Call the default create method from Devise
    else
      flash[:alert] = "Login is restricted to only the SecOps team 😎."
      redirect_to root_path
    end
  end
end