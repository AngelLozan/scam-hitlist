
ARG RUBY_VERSION=3.1.2
FROM --platform=linux/amd64 ruby:$RUBY_VERSION


RUN apt-get update && apt-get install -y nodejs yarn postgresql-client

RUN apt-get update -qq && \
    apt-get install -y build-essential libvips && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /usr/share/doc /usr/share/man


RUN mkdir /rails
WORKDIR /rails

ARG RAILS_MASTER_KEY
ENV RAILS_LOG_TO_STDOUT="1" \
    RAILS_SERVE_STATIC_FILES="true" \
    RAILS_ENV="production" \
    BUNDLE_WITHOUT="development" \
    BUNDLE_DEPLOYMENT="1" \
    RAILS_MASTER_KEY=${RAILS_MASTER_KEY}

COPY Gemfile Gemfile.lock ./
RUN bundle install


COPY . .


RUN bundle exec bootsnap precompile --gemfile app/ lib/



EXPOSE 3000
CMD ["bin/rails", "server", "-b", "0.0.0.0"]