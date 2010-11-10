require 'rails'
require 'grandstand'
require 'grandstand/controller'
require 'grandstand/form_builder'
require 'grandstand/helper'
require 'grandstand/session'

module Grandstand
  class Application < Rails::Engine
    initializer 'grandstand.initialize', :after => :load_application_initializers do |app|
      # Add sessions for Flash file uploads - but this is *not* very secure!
      app.middleware.insert_before(ActionDispatch::ShowExceptions, Grandstand::Session, app.config.session_options[:key] || app.config.session_options['key'])

      # Extend ActionController and ActionView to have the Grandstand defaults (current_user and its friends)
      ActionController::Base.send :include, Grandstand::Controller

      # Include Grandstand view helpers (page content and its friends)
      ActionView::Base.send :include, Grandstand::Helper
      ActionView::Helpers::FormBuilder.send :include, Grandstand::FormBuilder

      # Add Paperclip padded_id and dimensions interpolations
      Paperclip.interpolates :dimensions do |attachment, style|
        attachment.options[:styles][style].gsub(/[^\dx]/, '')
      end
      Paperclip.interpolates :gallery_id do |attachment, style|
        attachment.instance.gallery_id.to_s.rjust(6, '0')
      end
      Paperclip.interpolates :padded_id do |attachment, style|
        attachment.instance.id.to_s.rjust(6, '0')
      end
    end

    if Rails.env.development?
      # In development mode, Grandstand will serve static assets. Be sure to move them to your app's
      # actual public directory when you're ready to deploy using rake something something
      # TODO: Find actual rake task
      initializer 'grandstand.development_mode', :after => :load_application_initializers do |app|
        # app.middleware.insert_after ::ActionDispatch::Static, ::ActionDispatch::Static, "#{root}/public"
      end
    end
  end
end
