case Rails.env
when 'development'
  Grandstand.admin[:domain] = 'localhost'
when 'production'
  Grandstand.admin[:domain] = 'example.com'
end

Grandstand.image_sizes = {
  # Add your own image sizes here. Accepts any basic ImageMagick geometry string (including the
  # Paperclip-specific extensions)
  # :icon => '75x75#',
  # :page => '541x'
}

Grandstand.s3[:bucket] = 'changeme'
Grandstand.routing[:domain] = 'fmi.heroku.com'

# Comment this in for Heroku, which likes this for Paperclip to work.
# if Rails.env.development?
#   Paperclip.options[:bin_path] = '/usr/local/bin/identify'
# end
