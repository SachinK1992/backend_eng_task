FROM ruby:3.0.1-alpine
ENV BUILD_PACKAGES bash curl-dev build-base
# Update and install all of the required packages.
# At the end, remove the apk cache
RUN apk update && \
    apk upgrade && \
    apk add --no-cache $BUILD_PACKAGES
RUN mkdir /usr/app
WORKDIR /usr/app
COPY Gemfile /usr/app/
COPY Gemfile.lock /usr/app/
RUN gem install bundler -v 2.2.15
RUN bundle install
COPY . /usr/app
