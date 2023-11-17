#!/usr/bin/env bash

# Precompile assets
echo "Compiling assets, stand by for lots of output...."
bundle exec rake assets:precompile
echo "Assets precompiled! Pipeline ready."

# Wait for database to be ready. For Docker-Compose database as service.
  set -xeu pipefail
  ./services.sh db 5432
  ./services.sh redis 6379
  if [[ -f ./tmp/pids/server.pid ]]; then
    rm ./tmp/pids/server.pid
  fi
  bundle
echo "Postgres is up and running!"

# If the database exists, migrate. Otherwise setup (create and migrate)
bundle exec rake db:migrate db:seed 2>/dev/null || bundle exec rake db:create db:migrate db:seed
echo "Postgres database has been created & migrated!"

# Remove a potentially pre-existing server.pid for Rails.
rm -f tmp/pids/server.pid

# Run the Rails server
echo "Starting server"
bundle exec rails server -b 0.0.0.0 -p 8080