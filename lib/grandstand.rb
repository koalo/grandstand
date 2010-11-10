# Require the Gems we need for this guy
gem 'aws-s3'
require 'aws/s3'
require 'mustache'
require 'paperclip'

require 'grandstand/application'

module Grandstand
  # Some basic configuration options - app name ('Grandstand'), image sizes, content areas, etc.
  class << self
    def routing
      @routing ||= {:ssl => true}
    end

    def routing=(routing)
      @routing = new_routing
    end

    def routing_options
      routing_options = {}
      if Grandstand.routing[:domain]
        routing_options.merge!(:path => '', :constraints => {:domain => Grandstand.routing[:domain]})
      end
      routing_options
    end

    def app_name
      @app_name ||= 'Grandstand'
    end

    def image_sizes
      @images_sizes ||= {}
    end

    def image_sizes=(new_image_sizes)
      @images_sizes = new_image_sizes
    end

    def page_sections
      @page_sections ||= %w(left main)
    end

    def page_sections=(new_page_sections)
      @page_sections = new_page_sections
    end

    def s3
      @s3 ||= {
        :bucket => nil,
        :credentials => File.join(Rails.root, 'config', 's3.yml')
      }
    end

    def s3=(new_s3)
      @s3 = new_s3
    end
  end
end
