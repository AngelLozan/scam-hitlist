require 'rails_helper'

RSpec.describe Host, type: :model do
  subject { Host.new(name: 'test', email: 'email@example.com') }

  it 'is valid with valid attributes' do
    expect(subject).to be_valid
  end

  it 'is not valid without an email' do
    subject.email = nil
    expect(subject).to_not be_valid
  end
end
