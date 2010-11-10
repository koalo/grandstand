class Grandstand::MainController < ApplicationController
  skip_before_filter :find_page
  before_filter :require_user
  if Rails.env.production?
    before_filter :require_ssl
  end
  before_filter :set_return_path, :only => [:index, :show]

  layout :grandstand_layout

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
  def grandstand_layout
    request.xhr? ? 'grandstand_xhr' : 'grandstand'
  end

  def grandstand_not_found(options = {})
    options = {:layout => 'minimal', :status => 404, :template => 'shared/404'}.merge(options)
    render options
    false
  end

  def find_gallery
    return grandstand_not_found unless @gallery = Grandstand::Gallery.where(:id => params[:gallery_id] || params[:id]).first
  end

  def require_no_user
    redirect_to return_path || grandstand_root_path if current_user
  end

  def require_ssl
    if !request.ssl?
      new_url = Grandstand.routing[:domain] ? url_for(:protocol => 'https', :host => Grandstand.routing[:domain]) : url_for(:protocol => 'https')
      redirect_to new_url
    end
  end
end
