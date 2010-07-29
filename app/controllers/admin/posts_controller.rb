class Admin::PostsController < Admin::MainController
  before_filter :find_post, :except => [:create, :index, :new]
  layout :check_form_layout

  def create
    @post = Post.new(params[:post].merge(:user => current_user))
    if @post.save
      flash[:success] = "#{@post.name} was successfully added"
      redirect_to admin_post_path(@post)
    else
      flash[:error] = 'There was a problem creating this post'
      render :new
    end
  end

  def destroy
    @post.destroy
    flash[:delete] = 'Your post has been deleted'
    redirect_to admin_posts_path
  end

  def index
    @posts = Post.all
  end

  def new
    @post = Post.new
  end

  def update
    if @post.update_attributes(params[:post])
      flash[:success] = "#{@post.name} was successfully saved"
      request.xhr? ? render(:json => {:status => :ok}) : redirect_to(admin_post_path(@post))
    else
      flash[:error] = 'There was a problem saving this post'
      render :edit
    end
  end

  protected
  def check_form_layout
    %w(create edit new update).include?(params[:action]) && params[:preview] == 'yup' ? 'application'  : admin_layout
  end

  def find_post
    return admin_not_found unless @post = Post.where(:id => params[:id]).first
  end
end
