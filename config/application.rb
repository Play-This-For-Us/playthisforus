# frozen_string_literal: true
require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Playthisforus
  class Application < Rails::Application
    config.action_view.field_error_proc = proc { |html_tag|
      "<span class=\"\">#{html_tag}</span>".html_safe
    }

    config.generators do |g|
      g.template_engine :haml
    end
  end
end
