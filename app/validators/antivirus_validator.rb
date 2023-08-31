# frozen_string_literal: true

class AntivirusValidator < ActiveModel::Validator
  def validate(record)
    if file(record).path && File.exist?(file(record).path) && Clamby.virus?(file(record).path)
      record.errors.add(options[:attribute_name].to_sym, I18n.t('infected_file'))
    end
  end

  private

  def file(record)
    record.public_send(options[:attribute_name].to_sym)
  end
end