require 'rails'
require 'grandstand'

module Grandstand
  class Application < Rails::Engine
    paths.config.routes = 'lib/routes.rb'
    
    initializer 'grandstand.add_session_extension', :after => :load_application_initializers do |app|
      puts "Adding middleware (#{app.config.session_options.inspect})"
      app.middleware.insert_before(ActionDispatch::ShowExceptions, Grandstand::Session, app.config.session_options[:key] || app.config.session_options['key'])
      Grandstand.initialize!
    end
    
    initializer 'grandstand.symlink_public_files' do |app|
      Dir[File.join(File.dirname(__FILE__), '..', 'public', '*')].each do |gem_path|
        user_path = File.join(app.root, 'public', File.basename(gem_path))
        puts "Copying #{gem_path} to #{user_path}"
        if File.file?(gem_path) && !File.file?(user_path)
          FileUtils.cp_r(gem_path, user_path)
        elsif File.directory?(gem_path) && !File.directory?(user_path)
          FileUtils.cp_r(gem_path, user_path)
        end
      end
    end

    class << self
      def app_name
        @app_name ||= 'Portfoliawesome'
      end

      def image_sizes
        {
          :icon => '75x75#',
          :page => '541x' 
        }
      end

      def page_sections
        %w(left main)
      end

      def s3
        @s3 ||= {
          :bucket => nil,
          :credentials => File.join(Rails.root, 'config', 's3.yml')
        }
      end
    end
  end
end
