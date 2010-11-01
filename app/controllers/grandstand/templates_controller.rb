class Grandstand::TemplatesController < Grandstand::MainController
  def show
    return grandstand_not_found unless @template = Grandstand::Template[params[:id]]
    render :text => @template.render
  end
end
