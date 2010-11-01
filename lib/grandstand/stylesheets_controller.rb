require 'less'
module Grandstand
  class StylesheetsController < ApplicationController
    def show
      stylesheet = File.join(Grandstand::Application.root, 'app', 'stylesheets', "#{params[:name]}.less")
      if File.file?(stylesheet)
        engine = File.open(stylesheet) {|file| Less::Engine.new(file) }
        render :content_type => 'text/css', :text => engine.to_css
      else
        grandstand_not_found
      end
    end
  end
end
