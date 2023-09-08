require "date"
require 'net/http'
require 'json'
require "uri"

class Ioc < ApplicationRecord
  before_save :add_protocol_to_url
  before_save :set_removed_date, if: :status_changed_to_resolved?
  has_one_attached :file, dependent: :destroy, service: :amazon
  after_save :enqueue_scan
  enum :status, { added: 0, reported: 1, resolved: 2, official_url: 3, watchlist: 4 }
  enum :zf_status, { not_sub_zf: 0, submitted_zf: 1 } # Used for buttons on show page
  enum :ca_status, { not_sub_ca: 0, submitted_ca: 1 }
  enum :pt_status, { not_sub_pt: 0, submitted_pt: 1 }
  enum :gg_status, { not_sub_gg: 0, submitted_gg: 1 }
  validates :url, presence: true
  validates :url, uniqueness: true
  # validate :virus_scan
  # validates :report_method_one, presence: true
  paginates_per 10

  include PgSearch::Model
  pg_search_scope :search_by_url,
                  against: %i[status url],
                  using: {
                    tsearch: { prefix: true }
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
    Integer(str)
  rescue StandardError
    false
  end

  def protocol_to_url
    if url.present? && !url.start_with?('http://', 'https://')
      self.url = "http://#{url}"
    elsif url.present? && url.start_with?('http://', 'https://')
      self.url = url
    end
  end

  private

  def status_changed_to_resolved?
    status_changed? && status == 'resolved'
  end

  def set_removed_date
    self.removed_date ||= Date.current
  end

  def add_protocol_to_url
    return unless url.present? && !url.start_with?('http://', 'https://')

    self.url = "http://#{url}"
  end

  def virus_total(file_upload)
    api_key = ENV['VIRUS_TOTAL']
    vtscan = VirustotalAPI::File.upload(file_upload, api_key)
    upload_id = vtscan.id
    puts "========================================="
    puts "===========>> #{vtscan.id} <=="
    puts "========================================="

    # Enqueue the check_scan method with a delay of 5 minutes
    enqueue_check_scan(upload_id, 20.minutes.from_now)

  end


  # Method to check the scan results
  def check_scan(upload_id)
    url = URI("https://www.virustotal.com/vtapi/v2/file/report?apikey=#{ENV['VIRUS_TOTAL']}&resource=#{upload_id}&allinfo=true")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true

    request = Net::HTTP::Get.new(url)

    response = http.request(request)
    parsed_response = JSON.parse(response.read_body)
    positives_count = parsed_response["positives"]
    puts "Positives count: #{positives_count}"
    
    if positives_count > 0
      self.file.purge
    else
      return true
    end
  end

    # Enqueue the check_scan method with a specified delay
  def enqueue_scan
    file_id = virus_total(self.file)
    CheckScan.set(wait: 20.minutes).perform_later(file_id, self.id)
  end

  #  def virus_scan
  #   if file.attached? && file.blob.present? && Clamby.virus?(file.blob)
  #     file.purge
  #     errors.add(:file, 'contains a virus')
  #   end
  # end
end
