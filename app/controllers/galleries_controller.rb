class GalleriesController < ApplicationController
  def index
    @galleries = Grandstand::Gallery.where(:published => true).paginate(:page => params[:page])
  end

  def show
    @gallery = Grandstand::Gallery.where(:id => params[:id]).first
  end
end
