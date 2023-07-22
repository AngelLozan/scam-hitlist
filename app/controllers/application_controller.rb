# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  add_flash_types :alert_primary, :alert_danger, :alert_success, :alert_warning, :alert_blue
end
