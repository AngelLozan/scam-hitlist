# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  add_flash_types :alert_primary, :alert_danger, :alert_success, :alert_warning, :alert_blue
  # before_action :allow_cross_domain_access
  # after_action :cors_set_access_control_headers

  # def allow_cross_domain_access
  #     headers['Access-Control-Allow-Origin'] = 'http://127.0.0.1:3000'
  #     headers['Access-Control-Allow-Headers'] = 'GET, POST, PUT, DELETE, OPTIONS'
  #     headers['Access-Control-Allow-Methods'] = %w{Origin Accept Content-Type X-Requested-With X-CSRF-Token}.join(',')
  #     headers['Access-Control-Max-Age'] = '1728000'
  # end

  # def cors_set_access_control_headers
  #         headers['Access-Control-Allow-Origin'] = 'http://127.0.0.1:3000'
  #         headers['Access-Control-Allow-Methods'] = 'POST, GET, OPTIONS'
  #         headers['Access-Control-Allow-Headers'] = %w{Origin Accept Content-Type X-Requested-With X-CSRF-Token}.join(',')
  #         headers['Access-Control-Max-Age'] = "1728000"
  # end

end
