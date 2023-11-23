class HealthController < ApplicationController
  skip_before_action :authenticate_user!, only:%i[readiness liveness]
  skip_after_action :verify_authorized, only: %i[readiness liveness]

  def readiness
    if ready_to_serve?
      render plain: 'OK', status: 200
    else
      render plain: 'Service Unavailable', status: 503
    end
  end

  def liveness
    render plain: 'OK', status: 200
  end

  private

  def ready_to_serve?
    ActiveRecord::Base.connected? && db_connected?
  end

  def db_connected?
    begin
      ActiveRecord::Base.connection.execute('SELECT 1')
      true
    rescue ActiveRecord::StatementInvalid
      false
    end
  end
end
