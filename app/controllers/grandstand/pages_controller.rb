class Grandstand::PagesController < Grandstand::MainController
  before_filter :find_page, :except => [:create, :index, :new]
  before_filter :build_page_sections, :only => [:edit]

  def create
    @page = Grandstand::Page.new(params[:page])
    if @page.save
      flash[:success] = "#{@page.name} was successfully added"
      redirect_to grandstand_page_path(@page)
    else
      flash[:error] = 'There was a problem creating this page'
      render :new
    end
  end

  def destroy
    @page.destroy
    flash[:delete] = 'Your page has been deleted'
    redirect_to grandstand_pages_path
  end

  def index
    @pages = Grandstand::Page.where(:parent_id => nil).all
  end

  def new
    @page = Grandstand::Page.new
    build_page_sections
  end

  def update
    if @page.update_attributes(params[:page])
      flash[:success] = "#{@page.name} was successfully saved"
      request.xhr? ? render(:json => {:status => :ok}) : redirect_to(grandstand_page_path(@page))
    else
      flash[:error] = 'There was a problem saving this page'
      render :edit
    end
  end

  protected
  def build_page_sections
    Grandstand.page_sections.each do |page_section|
      @page.page_sections.where(:section => page_section).first || @page.page_sections.build(:section => page_section)
    end
  end

  def find_page
    return grandstand_not_found unless @page = Grandstand::Page.where(:id => params[:id]).first
  end
end
