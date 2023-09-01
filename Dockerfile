# Use Alpine Linux as the base image
FROM --platform=linux/amd64 ruby:3.1.2-alpine3.15

# Install Git
RUN apk add --no-cache git

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
    RAILS_ENV="development" \
    BUNDLE_WITHOUT="test" \
    RAILS_MASTER_KEY=${RAILS_MASTER_KEY}

ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser
ENV CHROMIUM_FLAGS "--no-sandbox --disable-setuid-sandbox"

# RUN yarn add puppeteer@13.5.0

COPY Gemfile ${APP_HOME}/Gemfile
COPY Gemfile.lock ${APP_HOME}/Gemfile.lock

COPY Gemfile Gemfile.lock ./


RUN gem install bundler -v 2.4.13 && bundle install --jobs 20 --retry 5

COPY . .

RUN yarn install && yarn build

RUN bundle exec bootsnap precompile --gemfile app/ lib/


EXPOSE 8080
ENTRYPOINT ["sh", "./entrypoint.sh"]
