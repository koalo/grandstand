class Grandstand::UsersController < Grandstand::MainController
  before_filter :find_user, :except => [:create, :index, :new]

  def create
    @user = Grandstand::User.new(params[:user])
    if @user.save
      flash[:success] = "#{@user.name} was successfully added"
      redirect_to grandstand_user_path(@user)
    else
      flash[:error] = 'There was a problem creating this user'
      render :new
    end
  end

  def delete
    return grandstand_not_found if @user.id == current_user.id
  end

  def destroy
    return grandstand_not_found if @user.id == current_user.id
    @user.destroy
    flash[:delete] = 'Your user has been deleted'
    redirect_to grandstand_users_path
  end

  def index
    @users = Grandstand::User.all
  end

  def new
    @user = Grandstand::User.new
  end

  def update
    if @user.update_attributes(params[:user])
      flash[:success] = "#{@user.name} was successfully saved"
      request.xhr? ? render(:json => {:status => :ok}) : redirect_to(grandstand_user_path(@user))
    else
      flash[:error] = 'There was a problem saving this user'
      render :edit
    end
  end

  protected
  def find_user
    return grandstand_not_found unless @user = User.where(:id => params[:id]).first
  end
end
