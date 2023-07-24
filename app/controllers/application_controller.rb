# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  add_flash_types :alert_primary, :alert_danger, :alert_success, :alert_warning, :alert_blue
  before_action :set_theme

  def set_theme
    return unless params[:theme].present?

    theme = params[:theme].to_sym
    # session[:theme] = theme
    cookies[:theme] = theme
    redirect_to(request.referrer || root_path)
  end
end
