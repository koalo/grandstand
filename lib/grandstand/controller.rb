module Grandstand
  # The Grandstand::Controller mixin will add a number of ActionController and ActionView
  # helper methods that will allow you to require a user and other cool stuff like that.
  # 
  # It's not the most functional beast you've ever seen, but Grandstand aims to be as
  # unobtrusive as possible. It doesn't, for example, do anything to mess with how
  # Rails is supposed to work.
  module Controller
    def self.included(base) #:nodoc:
      base.helper_method :current_page, :current_user, :return_path
    end

    protected
    # current_page returns a Page instance for any page that exists for the
    # the current requests' URL. Very frequently nil!
    def current_page
      return @_current_page if defined? @_current_page
      @_current_page = Grandstand::Page.where(:url => request.path.reverse.chomp('/').reverse).first
    end
    protected :current_page

    # Predictably, `current_user` will return the currently logged-in user.
    def current_user
      # Ask Rack for a model first - this makes it easy to add SSO middleware
      @_user ||= request.env['user'] || Grandstand::User.first(:conditions => {:id => session[:user_id]}) if session[:user_id]
    end
    protected :current_user

    # not_found is a quick and easy way to render a 404 error page without much overhead.
    # You can pass it options which are just render options that get merged on top of the
    # defaults, which are to render the application layout, with a 404 status, and the
    # shared/404 template. That's it!
    # 
    # Also of note, it returns false so you can very easily integrate it into before_filter
    # and do stuff like:
    # 
    #   class PostsController < ApplicationController
    #     before_filter :find_post, :except => :index
    # 
    #     ...
    # 
    #     protected
    #     def find_post
    #       not_found unless @post = Post.first(:conditions => {:id => params[:id]})
    #     end
    #   end
    # 
    def not_found(options = {})
      options = {:layout => 'application', :status => 404, :template => 'shared/404'}.merge(options)
      render options
      false
    end

    # Require a user for this action - use as a before filter, as in:
    #   before_filter :require_user, :only => [:show]
    def require_user
      # Require a logged in model
      unless current_user
        # Remember where we started
        set_return_path
        # Remember any post variables the user may have sent between logout and now.
        # session[:post_params] = params.except(:controller, :action, :id).merge({:_method => request.method}) unless request.get?
        # Send them off to the correct login path
        redirect_to(grandstand_session_path) and return false
      end
    end              

    # return_path gives you the current return_path as set by set_return_path. Use them
    # together to ensure users are returned to a contextually correct location whenever
    # possible. Also used as a helper method so you can point cancel buttons to the 
    # contextually correct resource, e.g.:
    # 
    #   <% form_for(@post) do |form| %>
    #     ...
    #     <%= form.submit "Save Post" %> or <%= link_to 'cancel', return_path || posts_path %>
    #   <% end %>
    # 
    # See set_return_path for more information.
    def return_path
      session[:return_path]
    end

    # Sets a return path for redirecting users to later on. For example, on a basic CRUD controller,
    # if your user goes straight to "edit" from the index action, chances are they want to return
    # to index when they're done, and likewise for the show action. So:
    # 
    #   class PostsController < ApplicationController
    #     before_filter :set_return_path, :only => [:index, :show]
    #
    #     ...
    #
    #     def update
    #       if @post.update_attributes(params[:post])
    #         redirect_to return_path || post_path(@post)
    #       else
    #         ...
    #       end
    #     end
    #   end
    # 
    # It's also a quick way to return a user to previous action post-login - see
    # Grandstand::SessionController#create for more details and an example
    def set_return_path(path = nil)
      session[:return_path] = path || request.fullpath
    end
    
  end
end
