class Admin::MainController < ApplicationController
  skip_before_filter :find_page
  before_filter :require_user, :except => [:login]
  before_filter :set_return_path, :only => [:index, :show]

  layout :admin_layout

  def expand
    session[:expand] ||= []
    if params[:add] == 'yup' && !session[:expand].include?(params[:section])
      session[:expand].push(params[:section])
    elsif params[:add] == 'nope'
      session[:expand].delete(params[:section])
    end
    render :text => ''
  end

  protected
  def admin_layout
    request.xhr? ? 'admin_xhr' : 'admin'
  end

  def admin_not_found
    options = {:layout => 'minimal', :status => 404, :template => 'shared/404'}.merge(options)
    render options
    false
  end

  def find_gallery
    return admin_not_found unless @gallery = Gallery.where(:id => params[:gallery_id] || params[:id]).first
  end

  def require_no_user
    redirect_to return_path || admin_root_path if current_user
  end
end
