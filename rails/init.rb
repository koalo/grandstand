require 'grandstand'
Grandstand.initialize!

config.after_initialize do |app|
  puts "Adding middleware (#{app.config.session_options.inspect})"
  app.middleware.insert_before(ActionDispatch::ShowExceptions, Grandstand::Session, app.config.session_options[:key] || app.config.session_options['key'])

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
