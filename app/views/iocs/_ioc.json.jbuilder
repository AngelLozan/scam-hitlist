# If review is saved, render ioc.
# Else render validation error json.

json.extract! ioc, :id, :url, :removed_date, :report_method_one, :report_method_two, :form, :host, :follow_up_date,
              :follow_up_count, :comments, :created_at, :updated_at, :file_url, :zf_status, :ca_status, :pt_status, :gg_status
json.url ioc_url(ioc, format: :json)
