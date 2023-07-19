require "date"

class Ioc < ApplicationRecord
  has_one_attached :file, dependent: :destroy
  enum :status, { added: 0, reported: 1, resolved: 2, official_url: 3, watchlist: 4 }
  enum :zf_status, { not_sub_zf: 0, submitted_zf: 1 } # Used for buttons on show page
  enum :ca_status, { not_sub_ca: 0, submitted_ca: 1 }
  enum :pt_status, { not_sub_pt: 0, submitted_pt: 1 }
  enum :gg_status, { not_sub_gg: 0, submitted_gg: 1 }
  validates :url, presence: true, uniqueness: true
  # validates :report_method_one, presence: true
  paginates_per 10

  include PgSearch::Model
  pg_search_scope :search_by_url,
                  against: %i[status url],
                  using: {
                    tsearch: { prefix: true },
                  }

  def self.all_count
    Ioc.where.not(status: :official_url).count
  end

  def self.reported_count
    where(status: 1).count
  end

  def self.follow_up_needed
    time = DateTime.now - 13
    where(status: 1).where("created_at < ?", time).where("follow_up_date IS NULL OR follow_up_date < ? ", time)
  end

  def self.tb_reported
    where(status: 0)
  end

  def self.watchlist
    where(status: 4)
  end

  def self.official_url
    where(status: 3)
  end

  def form_host_number?(str)
    Integer(str) rescue false
  end

end
