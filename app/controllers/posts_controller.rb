class PostsController < ApplicationController
  def show
    return not_found unless @post = Grandstand::Post.where({
      Grandstand::Post.extract_year('created_at') => params[:year],
      Grandstand::Post.extract_month('created_at') => params[:month].rjust(2, '0'),
      :url => params[:id]
    }).first
  end
end
