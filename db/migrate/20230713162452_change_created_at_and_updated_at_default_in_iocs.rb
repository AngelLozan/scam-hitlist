class ChangeCreatedAtAndUpdatedAtDefaultInIocs < ActiveRecord::Migration[7.0]
  def change
    change_column_default :iocs, :updated_at, from: nil, to: -> { 'NULL' }
    change_column_default :iocs, :created_at, from: nil, to: -> { 'NULL' }
    change_column_default :iocs, :removed_date, from: nil, to: -> { 'NULL' }
    change_column_default :iocs, :form, from: nil, to: -> { 'NULL' }
    change_column_default :iocs, :host, from: nil, to: -> { 'NULL' }
    change_column_default :iocs, :follow_up_count, from: nil, to: -> { 'NULL' }
    change_column_default :iocs, :follow_up_date, from: nil, to: -> { 'NULL' }
    change_column_default :iocs, :report_method_one, from: nil, to: -> { 'NULL' }
    change_column_default :iocs, :report_method_two, from: nil, to: -> { 'NULL' }
    change_column_default :iocs, :comments, from: nil, to: -> { 'NULL' }
  end
end
