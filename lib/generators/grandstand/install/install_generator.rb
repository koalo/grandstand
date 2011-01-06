module Grandstand
  module Generators
    class InstallGenerator < Rails::Generators::Base
      include Rails::Generators::Migration

      desc << %{
Description:
  Copy Grandstand static files and migrations to your application.
}

      def self.next_migration_number(dirname)
        if ActiveRecord::Base.timestamped_migrations
          Time.now.utc.strftime("%Y%m%d%H%M%S")
        else
          "%.3d" % (current_migration_number(dirname) + 1)
        end
      end

      def self.source_root
        @source_root ||= File.expand_path(File.join(File.dirname(__FILE__), 'templates'))
      end

      def copy_migration
        migration_template 'migration.rb', File.join('db' ,'migrate', 'install_grandstand.rb')
      end

      def copy_initializer
        template 'initializer.rb', File.join('config', 'initializers', 'grandstand.rb')
      end

      def copy_s3_yml
        template 's3.yml', File.join('config', 's3.yml')
      end

      def copy_static_files
        directory 'public', File.join('public', 'grandstand')
      end
    end
  end
end
