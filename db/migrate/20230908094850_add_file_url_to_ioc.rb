class AddFileUrlToIoc < ActiveRecord::Migration[7.0]
  def change
    add_column :iocs, :file, :string
  end
end
