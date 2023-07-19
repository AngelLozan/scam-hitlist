class AddApiSubmissionStatusToIoc < ActiveRecord::Migration[7.0]
  def change
    add_column :iocs, :zf_status, :integer, default: 0
    add_column :iocs, :ca_status, :integer, default: 0
    add_column :iocs, :pt_status, :integer, default: 0
    add_column :iocs, :gg_status, :integer, default: 0
  end
end
