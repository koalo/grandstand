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

      # Include Grandstand view helpers (page content and its friends)
      ActionView::Base.send :include, Grandstand::Helper
    end

    if Rails.env.development?
      # In development mode, Grandstand will serve static assets. Be sure to move them to your app's
      # actual public directory when you're ready to deploy using rake something something
      # TODO: Find actual rake task
      initializer 'grandstand.development_mode', :after => :load_application_initializers do |app|
        app.middleware.insert_after ::ActionDispatch::Static, ::ActionDispatch::Static, "#{root}/public"
      end
    end
  end
end
