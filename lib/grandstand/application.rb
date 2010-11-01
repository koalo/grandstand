require 'rails'
require 'grandstand'
require 'grandstand/controller'
require 'grandstand/helper'
require 'grandstand/session'

module Grandstand
  class Application < Rails::Engine
    initializer 'grandstand.initialize', :after => :load_application_initializers do |app|
      # Add sessions for Flash file uploads - but this is *not* very secure!
      app.middleware.insert_before(ActionDispatch::ShowExceptions, Grandstand::Session, app.config.session_options[:key] || app.config.session_options['key'])
      # Extend ActionController to have the Grandstand defaults (current_user and its friends)
      ActionController::Base.send :include, Grandstand::Controller
      # Add Paperclip padded_id interpolation for gallery images (pretty URLs)
      Paperclip.interpolates :padded_id do |attachment, style|
        attachment.instance.id.to_s.rjust(6, '0')
      end
    end

    # Serve admin assets in development mode. Be sure to run rake 
    if Rails.env.development?
      initializer 'grandstand.development_mode', :after => :load_application_initializers do |app|
        app.middleware.insert_after ::ActionDispatch::Static, ::ActionDispatch::Static, "#{root}/public"
        # Extend development mode to allow us to build our admin LESS files on-the-fly
        ActionController::Base.send :include, Grandstand::Controller::Development
        # Tell Less to produce the smallest stylesheets it's capable of
        Less::More.compression = true
        Less::More.header = false
        # Point More to our plugins' source_path and our custom admin stylesheets folder
        Less::More.source_path = File.join('vendor', 'plugins', 'grandstand', 'app', 'stylesheets')
        Less::More.destination_path = File.join('admin', 'stylesheets')
        ActionView::Base.send :include, Grandstand::Helper
      end
    end
  end
end
