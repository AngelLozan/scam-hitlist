class CheckScanJob < ApplicationJob
  queue_as :default

  def perform(upload_id, ioc_id)
    ioc = Ioc.find(ioc_id)
    ioc.check_scan(upload_id)
  end
end
