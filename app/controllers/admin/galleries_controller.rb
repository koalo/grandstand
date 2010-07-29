class Admin::GalleriesController < Admin::MainController
  before_filter :find_gallery, :except => [:create, :index, :new, :reorder]

  def create
    @gallery = Gallery.new(params[:gallery].merge(:user => current_user))
    if @gallery.save
      flash[:success] = "#{@gallery.name} was successfully added"
      redirect_to admin_gallery_path(@gallery)
    else
      flash[:error] = 'There was a problem creating this gallery'
      render :new
    end
  end

  def destroy
    @gallery.destroy
    flash[:delete] = 'Your gallery has been deleted'
    redirect_to admin_galleries_path
  end

  def index
    @galleries = Gallery.all
    if request.xhr?
      if params.has_key?(:image)
        render :editor_with_images
      else
        render :editor
      end
    end
  end

  def new
    @gallery = Gallery.new
  end

  def reorder
    params[:galleries].each_with_index do |gallery_id, index|
      Gallery.update(gallery_id, :position => index + 1)
    end if params[:galleries]
    render :json => {:status => :ok}
  end

  def update
    if @gallery.update_attributes(params[:gallery])
      flash[:success] = "#{@gallery.name} was successfully saved"
      request.xhr? ? render(:json => {:status => :ok}) : redirect_to(admin_gallery_path(@gallery))
    else
      flash[:error] = 'There was a problem saving this gallery'
      render :edit
    end
  end
end
