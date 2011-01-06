case Rails.env
when 'development'
  Grandstand.routing = {
    :domain => 'localhost',
    :ssl => false
  }
  Grandstand.s3[:bucket] = 'changeme'
when 'production'
  Grandstand.routing = {
    # :domain => 'example.com',
    # :ssl => true
  }
  Grandstand.s3[:bucket] = 'changeme_for_production'
end

# Comment this in ONLY if you're using SSL. It opens up a Rack-based security hole otherwise!
# Grandstand.multiple_upload = true

# Use the following to set which areas of a page you'd like to edit with Grandstand.
# Grandstand.page_sections = %w(left main)

# Add your own image sizes here. Accepts any basic ImageMagick geometry string, as well as the
# Paperclip-specific extensions
Grandstand.image_sizes = {
  # :icon => '75x75#',
  # :page => '541x'
}
