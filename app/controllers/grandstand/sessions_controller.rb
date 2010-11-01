class Grandstand::SessionsController < Grandstand::MainController
  before_filter :require_no_user, :except => [:destroy]
  skip_before_filter :require_user, :except => [:destroy]
  skip_before_filter :set_return_path
  layout 'grandstand_login'

  def create
    login_attempts = (session[:login_attempts] || 0).next
    if !params[:email].blank? && user = Grandstand::User.authenticates_with(:email => params[:email])
      if user.authenticates_with?(params[:password])
        saved_return_path = return_path
        reset_session
        session[:user_id] = user.id
        redirect_to saved_return_path || grandstand_root_path
        return
      else
        flash.now[:error] = 'The password you entered is incorrect. Please try again.'
      end
    else
      flash.now[:error] = 'An account with that e-mail could not be found. Please try again.'
    end
    session[:login_attempts] = login_attempts
    render :show
  end

  def destroy
    reset_session
    redirect_to grandstand_session_path
  end

  def reset
    if user = Grandstand::User.where(:email => params[:email]).first
      user.reset_password
      flash[:notice] = "A link containing password reset instructions has been sent to #{user.email}"
      redirect_to grandstand_session_path
    else
      flash[:error] = "There is no user account with that e-mail address!"
      redirect_to forgot_grandstand_session_path
    end
  end
end
