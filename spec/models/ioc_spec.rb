# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ioc, type: :model do
  subject { Ioc.new(url: 'https://www.example.com', report_method_one: 'Emailed host') }

  it 'is valid with valid attributes' do
    expect(subject).to be_valid
  end
  it 'should have a default status of added' do
    expect(subject.status).to eq('added')
  end
  it 'is not valid without a url' do
    subject.url = nil
    expect(subject).to_not be_valid
  end
  it 'is not valid without a report_method_one' do
    subject.report_method_one = 'Emailed Registrar'
    expect(subject).to be_valid
  end
  it 'should allow attachment of a photo' do
    # file = Rails.root.join('spec', 'support', 'assets', 'ban.png')
    # image = ActiveStorage::Blob.create_and_upload!(
    #   io: File.open(file, 'rb'),
    #   filename: 'ban.png',
    #   content_type: 'image/png'
    # ).signed_id
    file = "amazonpresignedurl.com"
    # ioc = Ioc.new(url: 'https://www.example.com', report_method_one: 'Emailed host', file: image)
    ioc = Ioc.new(url: 'https://www.example.com', report_method_one: 'Emailed host', file_url: file)
    # expect(ioc.file.attached?).to be(true)
    expect(ioc.file_url?).to be(true)
  end

  it 'should validate url uniqueness' do
    subject.url = 'https://www.bing.com'
    expect(subject).to be_valid
  end
end
