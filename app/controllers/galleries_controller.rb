class GalleriesController < ApplicationController
  def show
    @gallery = Gallery.where(:id => params[:id]).first
  end
end
