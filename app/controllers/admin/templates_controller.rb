class Admin::TemplatesController < Admin::MainController
  def show
    return admin_not_found unless @template = Template[params[:id]]
    render :text => @template.render
  end
end
