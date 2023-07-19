# frozen_string_literal: true

class CreateIocs < ActiveRecord::Migration[7.0]
  def change
    create_table :iocs do |t|
      t.string :url
      t.timestamp :removed_date
      t.string :report_method_one
      t.string :report_method_two
      t.string :form
      t.string :host
      t.timestamp :follow_up_date
      t.integer :follow_up_count
      t.text :comments

      t.timestamps
    end
  end
end
