class ChangeRemovedFollowUpDateToDateInIoc < ActiveRecord::Migration[7.0]
  def change
    change_column :iocs, :removed_date, :date
    change_column :iocs, :follow_up_date, :date
  end
end
