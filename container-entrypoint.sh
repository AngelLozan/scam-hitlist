#!/bin/bash
set -
pid=0

# SIGUSR1/SIGINT-handler (to catch ctrl-c signals when running docker manually)
int_handler() {
  echo "Caught SIGINT/SIGUSR1 code"
  if [ ! -z "$pid" ]; then
    pkill -P ${pid}
    wait "$pid"
  fi
  exit 130 # This is the exit code for sigint
}

# Setup our Kubernetes signal TERM handler so we can catch exits properly and cascade them to our service
term_handler() {
  echo "Caught SIGTERM code, propagating in 15s..."
  if [ ! -z "$pid" ]; then
    sleep 15 ## this delay is to make sure service endpoints are updated before we kill the pod
    pkill -P ${pid}
    wait "$pid"
  fi
  exit 143 # 128 + 15 -- SIGTERM
}
trap 'int_handler' SIGUSR1
trap 'int_handler' SIGINT
trap 'term_handler' SIGTERM

# Run migrations
# If the database exists, migrate. Otherwise setup (create and migrate)
echo "Running migrations"
secrets-manager-go -k RAILS_MASTER_KEY=SINGLE_STRING_SECRET -- bundle exec rake db:migrate 2>/dev/null || bundle exec rake db:create db:migrate

# Fetch secrets from AWS Secrets Manager, run the Rails server, and store PID to $pid
echo "Starting server"
secrets-manager-go -k RAILS_MASTER_KEY=SINGLE_STRING_SECRET -- bundle exec rails server -b 0.0.0.0
pid="$!"
echo "Found pid: $pid"

# Waiting for the pid to settle just in case to prevent false negatives/positives below
sleep 1

# Ensure we got a pid (if the command is invalid it won't)
if [ -z "$pid" ]; then
  echo "Program did not startup successfully"
  exit 1
fi

# Ensure the pid is still running (incase it crashed)
ls -la /proc/${pid} >/dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "Couldn't find the program running"
  exit 1
fi

# Wait forever for our backgrounded application to quit (directly, or from us via a signal kill)
while true; do
  tail -f /dev/null &
  wait ${!}
done
