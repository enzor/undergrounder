FROM ruby:1.9.3

RUN mkdir /workspace
ADD . /workspace
WORKDIR /workspace
RUN bundle install
RUN bundle exec rspec spec
