# syntax=docker/dockerfile:1
# Secrets Manager
ARG SECRETS_MANAGER_GO_VERSION=v1.4.0
FROM 534042329084.dkr.ecr.us-east-1.amazonaws.com/infrastructure/secrets-manager-go:${SECRETS_MANAGER_GO_VERSION} as secrets-manager

# Builder and Runner image
FROM 534042329084.dkr.ecr.us-east-1.amazonaws.com/exodus/base-docker-images:amazonlinux2023-ruby3.1

ENV \
  RAILS_LOG_TO_STDOUT="1" \
  RAILS_SERVE_STATIC_FILES="true" \
  RAILS_ENV="production" \
  BUNDLE_WITHOUT="test"

COPY --from=secrets-manager --chmod=755 /secrets-manager-go /bin/secrets-manager-go

#Install Node20, and psql-devel
RUN --mount=type=cache,target=/var/cache/yum \
  yum install -y https://rpm.nodesource.com/pub_20.x/nodistro/repo/nodesource-release-nodistro-1.noarch.rpm && \
  yum install -y nodejs --setopt=nodesource-nodejs.module_hotfixes=1 && \
  npm install -g yarn npm && \
  yum install -y postgresql-devel

RUN groupadd --gid 1000 ruby && \
  useradd --uid 1000 --gid ruby --shell /bin/bash --create-home ruby

WORKDIR /home/ruby/build

COPY --chown=ruby:ruby package.json yarn.lock Gemfile Gemfile.lock ./

# Install dependencies
RUN yarn install --frozen-lockfile && \
  gem install bundler -v 2.4.18 && \
  gem install dotenv && \
  bundle install --jobs 20 --retry 5

COPY --chown=ruby:ruby . .

RUN yarn build && \
  bundle exec bootsnap precompile --gemfile app/ lib/ 

RUN --mount=type=secret,id=rails_master_key,dst=/root/rails_master_key \
  export RAILS_MASTER_KEY=$(cat /root/rails_master_key) && \
  bin/rails assets:precompile

USER ruby

COPY --chown=ruby:ruby container-entrypoint.sh /usr/local/bin/container-entrypoint.sh

# # Uncomment below for running only as docker container. Responsible for starting redis and db.
# # ENTRYPOINT ["sh", "./entrypoint.sh"] 

ENTRYPOINT ["/usr/local/bin/container-entrypoint.sh"]