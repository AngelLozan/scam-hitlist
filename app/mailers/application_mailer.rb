# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: 'support@exodus.com'
  layout 'mailer'
end
