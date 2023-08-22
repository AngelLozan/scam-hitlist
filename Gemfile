# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.1.2'


# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem 'rails', '~> 7.0.6'

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem 'sprockets-rails'

# Use postgresql as the database for Active Record
gem 'pg', '~> 1.1'

# Use the Puma web server [https://github.com/puma/puma]
gem 'puma', '~> 5.0'

# Bundle and transpile JavaScript [https://github.com/rails/jsbundling-rails]
gem 'jsbundling-rails'

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem 'turbo-rails'

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem 'stimulus-rails'

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem 'jbuilder'

# Use Redis adapter to run Action Cable in production
gem 'redis', '~> 4.0'

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false

# Use Sass to process CSS
gem 'sassc-rails'

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

gem 'autoprefixer-rails'
gem 'bootstrap', '~> 5.2'
gem 'cloudinary'
gem 'devise'
gem 'factory_bot', '~> 6.2', '>= 6.2.1'
gem 'font-awesome-sass', '~> 6.1'
gem 'omniauth-google-oauth2'
gem 'omniauth-rails_csrf_protection'
gem 'uri', '~> 0.10.0'
gem 'net-http', '~> 0.3.2'
gem 'kaminari'
gem "pg_search"
gem 'nokogiri'
gem 'simple_form', github: 'heartcombo/simple_form'
gem 'mail'
gem 'mime-types', '~> 3.1'
gem 'tzinfo-data' # For Docker image to work properly with alpine
gem 'puppeteer-ruby', '~> 0.45.3'
# Security audits for dependencies and code. 
gem 'bundler-audit', require: false
gem 'ruby_audit', require: false
gem "brakeman"
gem 'clamby', '~> 1.1' # Not used yet. 

group :development, :test, :production do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem 'byebug', platform: :mri
  gem 'debug', platforms: %i[mri mingw x64_mingw]
  gem 'dotenv-rails'
  gem "recaptcha"
  gem 'rspec-core', '~> 3.4', '>= 3.4.4'
  gem 'rspec-rails'
  gem 'rubocop', '~> 1.54', '>= 1.54.1'
  gem 'rack-cors', require: 'rack/cors'
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem 'web-console'

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem 'capybara'
  gem 'selenium-webdriver'
  gem 'webdrivers'
  gem 'database_cleaner'
end
