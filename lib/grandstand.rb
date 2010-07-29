require 'grandstand/application'

module Grandstand
  autoload(:Controller, 'grandstand/controller')
  autoload(:Helper, 'grandstand/helper')

  def self.initialize!(config = nil)
    if defined?(ActionController)
      ActionController::Base.send :include, Grandstand::Controller
      if Rails.env.development?
        ActionController::Base.send :include, Grandstand::Controller::Development
        # Tell Less to produce the smallest stylesheets it's capable of
        Less::More.compression = true
        Less::More.header = false
        # Point More to our plugins' source_path and our custom admin stylesheets folder
        Less::More.source_path = File.join('vendor', 'plugins', 'grandstand', 'app', 'stylesheets')
        Less::More.destination_path = File.join('admin', 'stylesheets')
      end
    end
    if defined?(ActionView)
      ActionView::Base.send :include, Grandstand::Helper
    end
    Paperclip.interpolates :padded_id do |attachment, style|
      attachment.instance.id.to_s.rjust(6, '0')
    end
  end
end
