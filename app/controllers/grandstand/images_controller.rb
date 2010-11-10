class Grandstand::ImagesController < Grandstand::MainController
  before_filter :find_gallery
  before_filter :find_image, :only => [:delete, :destroy, :edit, :show, :update]
  prepend_before_filter :relax_session, :only => :create
  # session :cookies_only => false, :only => :create

  def create
    @image = @gallery.images.new(params[:image])
    if @image.save
      flash[:success] = 'Your image was successfully uploaded'
      params.has_key?('Filename') || request.xhr? ? render(:json => {:status => :ok}) : redirect_to(grandstand_gallery_path(@gallery))
    else
      render :new
    end
  end

  def delete
  end

  def destroy
    @image.destroy
    flash[:delete] = 'Your image has been deleted'
    redirect_to grandstand_gallery_path(@gallery)
  end

  def edit
    @image = @gallery.images.find(params[:id])
  end

  def index
    redirect_to grandstand_gallery_path(@gallery)
  end

  def new
    @image = Grandstand::Image.new
  end

  def reorder
    params[:images].each_with_index do |image_id, index|
      @gallery.images.update(image_id, :position => index + 1)
    end if params[:images]
    render :json => {:status => :ok}
  end

  def update
    if @image.update_attributes(params[:image])
      flash[:success] = 'Your image was successfully saved'
      request.xhr? ? render(:json => {:status => :ok}) : redirect_to(grandstand_gallery_path(@gallery))
    else
      render :new
    end
  end

  def upload
  end

  protected
  def find_image
    @image = @gallery.images.find(params[:id])
  end

  def relax_session
    request.session_options[:cookies_only] = false
  end
end
