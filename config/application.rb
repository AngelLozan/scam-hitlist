# frozen_string_literal: true

require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module ScamHitlist
  class Application < Rails::Application
    config.generators do |generate|
      generate.assets false
      generate.helper false
      generate.test_framework :test_unit, fixture: false
    end
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins 'https://scam-hitlist-d.ot.exodus.com', 'http://127.0.0.1:3000'
        # resource 'https://scam-hitlist-d.ot.exodus.com/', :headers => :any, :methods => [:get, :post, :options]
        # resource '*', :headers => :any, :methods => [:get, :post, :options, :put]
        resource '*', headers: :any, methods: [:get, :post, :options, :put]
      end
    end

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
    config.active_job.queue_adapter = :delayed_job
  end
end
