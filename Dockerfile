# Use Alpine Linux as the base image
FROM --platform=linux/amd64 ruby:3.1.2-alpine3.15

# Install Git
RUN apk add --no-cache git

RUN gem install dotenv

# Puppeteer Tooling
RUN apk add --no-cache \
    chromium \
    nss \
    freetype \
    harfbuzz \
    ca-certificates \
    ttf-freefont \
    nodejs \
    yarn \
    libpq \
    libpq-dev \
    postgresql-client \
    xdg-utils \
    at-spi2-atk \
    libdrm \
    libxkbcommon \
    libxcomposite \
    libxdamage \
    libxfixes \
    libxrandr \
    build-base


ENV APP_HOME /workdir
RUN mkdir ${APP_HOME}
WORKDIR ${APP_HOME}


# Change env to production if needed.
ARG RAILS_MASTER_KEY
ENV RAILS_LOG_TO_STDOUT="1" \
    RAILS_SERVE_STATIC_FILES="true" \
    RAILS_ENV="production" \
    BUNDLE_WITHOUT="test" \
    RAILS_MASTER_KEY=$RAILS_MASTER_KEY

ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser
ENV CHROMIUM_FLAGS "--no-sandbox --disable-setuid-sandbox"

# RUN yarn add puppeteer@13.5.0

COPY Gemfile ${APP_HOME}/Gemfile
COPY Gemfile.lock ${APP_HOME}/Gemfile.lock

COPY Gemfile Gemfile.lock ./


RUN gem install bundler -v 2.4.13 && bundle install --jobs 20 --retry 5

COPY . /workdir

RUN yarn install && yarn build

RUN bundle exec bootsnap precompile --gemfile app/ lib/

RUN bundle exec rake assets:precompile

EXPOSE 8080

# Uncomment below for running only as docker container. Responsible for starting redis and db.
# ENTRYPOINT ["sh", "./entrypoint.sh"] 

CMD ["./bin/rails", "server", "-b", "0.0.0.0"]
