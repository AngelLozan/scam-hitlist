class ChangeCreatedAtAndUpdatedAtNullableInIocs < ActiveRecord::Migration[6.0]
  def change
    change_column_null :iocs, :created_at, true
    change_column_null :iocs, :updated_at, true
  end
end
