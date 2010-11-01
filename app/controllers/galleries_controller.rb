class GalleriesController < ApplicationController
  def show
    @gallery = Grandstand::Gallery.where(:id => params[:id]).first
  end
end
