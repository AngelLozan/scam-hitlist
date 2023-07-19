# frozen_string_literal: true

class AddImageToUser < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :image, :string
  end
end
