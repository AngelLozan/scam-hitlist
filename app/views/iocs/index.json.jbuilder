# frozen_string_literal: true

json.array! @iocs, partial: 'iocs/ioc', as: :ioc
