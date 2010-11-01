class Grandstand::PostsController < Grandstand::MainController
  before_filter :find_post, :except => [:create, :index, :new]
  layout :check_form_layout

  def create
    @post = Grandstand::Post.new(params[:post].merge(:user => current_user))
    if @post.save
      flash[:success] = "#{@post.name} was successfully added"
      redirect_to grandstand_post_path(@post)
    else
      flash[:error] = 'There was a problem creating this post'
      render :new
    end
  end

  def destroy
    @post.destroy
    flash[:delete] = 'Your post has been deleted'
    redirect_to grandstand_posts_path
  end

  def index
    @posts = Grandstand::Post.all
  end

  def new
    @post = Grandstand::Post.new
  end

  def update
    if @post.update_attributes(params[:post])
      flash[:success] = "#{@post.name} was successfully saved"
      request.xhr? ? render(:json => {:status => :ok}) : redirect_to(grandstand_post_path(@post))
    else
      flash[:error] = 'There was a problem saving this post'
      render :edit
    end
  end

  protected
  def check_form_layout
    %w(create edit new update).include?(params[:action]) && params[:preview] == 'yup' ? 'application'  : grandstand_layout
  end

  def find_post
    return grandstand_not_found unless @post = Grandstand::Post.where(:id => params[:id]).first
  end
end
