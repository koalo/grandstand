class PostsController < ApplicationController
  def show
    return not_found unless @post = Post.where("#{Post.extract_year('created_at')} = ? AND #{Post.extract_month('created_at')} = ? AND url = ?", params[:year], params[:month].rjust(2, '0'), params[:id]).first
  end
end
