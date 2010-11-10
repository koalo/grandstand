class Grandstand::TemplatesController < Grandstand::MainController
  skip_before_filter :set_return_path

  def show
    return grandstand_not_found unless @template = Grandstand::Template[params[:id]]
    render :text => @template.render
  end
end
