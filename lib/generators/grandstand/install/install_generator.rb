module Grandstand
  module Generators
    class InstallGenerator < Rails::Generators::Base
      include Rails::Generators::Migration

      desc << %{
Description:
  Copy Grandstand static files and migrations to your application.
}

      def self.source_root
        @source_root ||= File.expand_path(File.join(File.dirname(__FILE__), 'templates'))
      end

      def copy_migration
        migration_template 'migration.rb', File.join('db' ,'migrate', 'install_grandstand.rb')
      end

      def copy_static_files
        directory 'public', File.join('public', 'grandstand')
      end
    end
  end
end
