class Grandstand::PostsController < Grandstand::MainController
  before_filter :find_post, :except => [:create, :index, :new]

  def create
    @post = Grandstand::Post.new(params[:post].merge(:user => current_user))
    if @post.save
      flash[:success] = "#{@post.name} was successfully added"
      redirect_to grandstand_post_path(@post)
    else
      flash[:error] = 'There was a problem creating this post'
      if preview?
        render :preview, :layout => 'application'
      else
        render :new
      end
    end
  end

  def destroy
    @post.destroy
    flash[:delete] = 'Your post has been deleted'
    redirect_to grandstand_posts_path
  end

  def edit
    if preview?
      render :preview, :layout => 'application'
    end
  end

  def index
    @posts = Grandstand::Post.all
  end

  def new
    @post = Grandstand::Post.new
    if preview?
      render :preview, :layout => 'application'
    end
  end

  def update
    if @post.update_attributes(params[:post])
      flash[:success] = "#{@post.name} was successfully saved"
      request.xhr? ? render(:json => {:status => :ok}) : redirect_to(grandstand_post_path(@post))
    else
      flash[:error] = 'There was a problem saving this post'
      if preview?
        render :preview, :layout => 'application'
      else
        render :edit
      end
    end
  end

  protected
  def find_post
    return grandstand_not_found unless @post = Grandstand::Post.where(:id => params[:id]).first
  end

  def preview?
    params[:preview] == 'yup'
  end
end
