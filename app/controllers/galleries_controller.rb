class GalleriesController < ApplicationController
  def index
    @galleries = Grandstand::Gallery.where(:published => true).paginate(:page => params[:page])
  end

  def show
    return not_found unless @gallery = Grandstand::Gallery.where(:url => params[:id]).first
  end
end
