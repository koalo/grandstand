class PostsController < ApplicationController
  def show
    return not_found unless @post = Grandstand::Post.posted_on(params[:year], params[:month]).where(:url => params[:id]).first
  end
end
