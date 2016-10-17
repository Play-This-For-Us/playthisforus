FROM ruby:2.3.1

# Install required packages
# node is there because execjs needs it
# not sure whether or not we need build-essential
RUN apt-get update && apt-get install -y \
	build-essential \
	nodejs

# Create the working directory
RUN mkdir -p /playthis
WORKDIR /playthis

# Install our gems
COPY Gemfile Gemfile.lock ./
RUN gem install bundler && bundler install --jobs 4 --retry 5
RUN gem install foreman

# Copy over the project
COPY . ./

# Expose the web port
EXPOSE 3000
