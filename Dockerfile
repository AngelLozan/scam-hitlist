
ARG RUBY_VERSION=3.1.2
FROM --platform=linux/amd64 ruby:$RUBY_VERSION


ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD true

# Puppeteer Tooling
RUN apt-get update \
    && apt-get install -y wget gnupg \
    && wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' \
    && apt-get update \
    && apt-get install -y google-chrome-stable fonts-ipafont-gothic fonts-wqy-zenhei fonts-thai-tlwg fonts-kacst fonts-freefont-ttf libxss1 \
      --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

ADD https://github.com/Yelp/dumb-init/releases/download/v1.2.2/dumb-init_1.2.2_x86_64 /usr/local/bin/dumb-init
RUN chmod +x /usr/local/bin/dumb-init
ENTRYPOINT ["dumb-init", "--"]

# Other required tooling

# Install node from nodesource
RUN curl -sL https://deb.nodesource.com/setup_16.x | bash - \
  && apt-get install -y nodejs

# Install yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
  && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
  && apt-get update -qq \
  && apt-get install -y yarn


# RUN apt-get update && apt-get install -y nodejs yarn postgresql-client
RUN apt-get update && apt-get install -qq -y libpq-dev postgresql-client --fix-missing --no-install-recommends

RUN apt-get update -qq && \
    apt-get install -y build-essential libvips && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /usr/share/doc /usr/share/man


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

COPY Gemfile ${APP_HOME}/Gemfile
COPY Gemfile.lock ${APP_HOME}/Gemfile.lock

COPY Gemfile Gemfile.lock ./


RUN gem install bundler -v 2.3.22 && bundle install --jobs 20 --retry 5

COPY . .

RUN yarn install && yarn build

RUN bundle exec bootsnap precompile --gemfile app/ lib/

# Precompiling assets for production without requiring secret RAILS_MASTER_KEY
# RUN SECRET_KEY_BASE_DUMMY=1 bundle exec rails assets:precompile

# EXPOSE 3000
# CMD ["./bin/rails", "server", "-b", "0.0.0.0"]
# CMD ["google-chrome-stable"]

EXPOSE 8080
ENTRYPOINT ["sh", "./entrypoint.sh"]
