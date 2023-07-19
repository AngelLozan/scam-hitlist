# frozen_string_literal: true

class AddStatusToIoc < ActiveRecord::Migration[7.0]
  def change
    add_column :iocs, :status, :integer, default: 0
  end
end
