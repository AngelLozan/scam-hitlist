# frozen_string_literal: true

clamby_configs = {
  daemonize: true
}

clamby_configs[:config_file] = '/etc/clamav/clamd.conf'

Clamby.configure(clamby_configs)