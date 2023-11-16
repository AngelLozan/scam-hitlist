# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  include Pundit::Authorization
  before_action :configure_permitted_parameters, if: :devise_controller?
  add_flash_types :alert_primary, :alert_danger, :alert_success, :alert_warning, :alert_blue
  before_action :set_theme
  protect_from_forgery with: :exception

  def configure_permitted_parameters
    # For additional fields in app/views/devise/registrations/new.html.erb
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name])

    # For additional in app/views/devise/registrations/edit.html.erb
    devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name])
  end


  after_action :verify_authorized, except: :index, unless: :skip_pundit?
  after_action :verify_policy_scoped, only: :index , unless: :skip_pundit?
  # %i[ :index :follow_up :reported :tb_reported :watchlist  ]

 
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  def user_not_authorized
    flash[:alert] = "You are not authorized to perform this action."
    redirect_to(root_path)
  end

  def set_theme
    return unless params[:theme].present?

    theme = params[:theme].to_sym
    # session[:theme] = theme
    cookies[:theme] = theme
    redirect_to(request.referrer || root_path)
  end

private

  def skip_pundit?
    devise_controller? || params[:controller] =~ /(^(rails_)?admin)|(^pages$)/
  end
  
end
