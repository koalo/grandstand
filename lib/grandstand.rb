# Require the Gems we need for this guy
gem 'aws-s3'
require 'aws/s3'
require 'mustache'
require 'paperclip'

require 'grandstand/application'

# The Grandstand module is the central place to configure all of Grandstand's options
# and what-have-yous. The basic things to look out for are S3 storage settings, the
# various image_sizes you may want to enable your users to embed on the site, and the
# routing options for the admin interface, which allow you to scale security up or
# down as you see fit.
module Grandstand
  class << self
    # Returns a hash for the Grandstand interface's routing configuration. Options include
    # 
    #   :ssl => Require SSL whenever a user is in the Grandstand interface
    def routing
      @routing ||= {:ssl => true}
    end

    # Pass in a hash to set multiple routing options at once.
    def routing=(routing)
      @routing = new_routing
    end

    def routing_options # :nodoc:
      routing_options = {}
      # if Grandstand.routing[:domain]
      #   routing_options.merge!(:path => '', :constraints => {:domain => Grandstand.routing[:domain]})
      # end
      routing_options
    end

    def app_name # :nodoc:
      @app_name ||= 'Grandstand'
    end

    # Image sizes returns the current hash of custom image sizes you've set up for your users. You can
    # add and image size like so:
    # 
    #   Grandstand.image_sizes[:large] = "800x600#"
    # 
    # Where the key is the name and the value is the ImageMagick geometry instructions.
    def image_sizes
      @images_sizes ||= {}
    end

    # You can completely set your image_sizes hash here if you don't want to tweak on a per-key basis,
    # so something like this is also possible:
    # 
    #   Grandstand.image_sizes = {:icon => '75x75#', :large => '800x600>'}
    def image_sizes=(new_image_sizes)
      @images_sizes = new_image_sizes
    end

    def page_sections # :nodoc:
      @page_sections ||= %w(left main)
    end

    def page_sections=(new_page_sections) # :nodoc:
      @page_sections = new_page_sections
    end

    # Grandstand uses Paperclip to process and store uploaded gallery images to S3. By default, it reads
    # those configuration options from config/s3.yml, but you can also specify credentials or anything else
    # here, like so:
    # 
    #   Grandstand.s3[:credentials] = {:access_key_id => "foo", :secret_access_key => "bar"}
    # 
    # Note that you _must_ set a :bucket key or Grandstand will not know where to upload files. Currently,
    # it does not support any other storage engines. Sorry!
    def s3
      @s3 ||= {
        :bucket => nil,
        :credentials => File.join(Rails.root, 'config', 's3.yml')
      }
    end

    # You can also set a completely fresh hash of S3 options if you don't like setting a key at time, like so:
    # 
    #   Grandstand.s3 = {:bucket => "yourmom", :credentials => {:access_key_id => "foo", :secret_access_key => "bar"}}
    def s3=(new_s3)
      @s3 = new_s3
    end
  end
end
