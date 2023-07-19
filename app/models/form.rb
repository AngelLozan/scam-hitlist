class Form < ApplicationRecord
  validates :url, presence: true
  validates :name, presence: true
end
