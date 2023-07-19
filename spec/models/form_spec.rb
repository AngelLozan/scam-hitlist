require 'rails_helper'

RSpec.describe Form, type: :model do
  subject { Form.new(name: 'test', url: 'www.example.com') }

  it 'is valid with valid attributes' do
    expect(subject).to be_valid
  end

  it 'is not valid without a url' do
    subject.url = nil
    expect(subject).to_not be_valid
  end
end
