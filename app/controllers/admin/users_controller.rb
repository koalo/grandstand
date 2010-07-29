class Admin::UsersController < Admin::MainController
  before_filter :find_user, :except => [:create, :index, :new]

  def create
    @user = User.new(params[:user])
    if @user.save
      flash[:success] = "#{@user.name} was successfully added"
      redirect_to admin_user_path(@user)
    else
      flash[:error] = 'There was a problem creating this user'
      render :new
    end
  end

  def delete
    return admin_not_found if @user.id == current_user.id
  end

  def destroy
    return admin_not_found if @user.id == current_user.id
    @user.destroy
    flash[:delete] = 'Your user has been deleted'
    redirect_to admin_users_path
  end

  def index
    @users = User.all
  end

  def new
    @user = User.new
  end

  def update
    if @user.update_attributes(params[:user])
      flash[:success] = "#{@user.name} was successfully saved"
      request.xhr? ? render(:json => {:status => :ok}) : redirect_to(admin_user_path(@user))
    else
      flash[:error] = 'There was a problem saving this user'
      render :edit
    end
  end

  protected
  def find_user
    return admin_not_found unless @user = User.where(:id => params[:id]).first
  end
end
