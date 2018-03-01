class UsersController < ApplicationController
  before_action :logged_in_user, except: %i(show new create)
  before_action :load_user, only: %i(destroy show edit)
  before_action :correct_user, only: %i(edit update)
  before_action :admin_user, only: :destroy

  def index
    @users = User.where(activated: true).paginate page: params[:page]
  end

  def show; end

  def new
    @user = User.new
  end

  def create
    @user = User.new user_params
    if @user.save
      @user.send_activation_email
      flash[:info] = t ".check"
      redirect_to root_url
    else
      render :new
    end
  end

  def edit; end

  def update
    return render :edit unless @user.update_attributes user_params
    flash[:success] = t "users.update.notice"
    redirect_to @user
  end

  def destroy
    if @user.destroy
      flash[:success] = t "users.destroy.notice"
    else
      flash[:danger] = t "users.destroy.fail"
    end
    redirect_to users_url
  end

  private

  def user_params
    params.require(:user).permit :name, :email, :password, :password_confirmation
  end

  def logged_in_user
    unless logged_in?
      store_location
      flash[:danger] = t "users.edit.require"
      redirect_to login_url
    end
  end

  def correct_user
    load_user
    redirect_to root_url unless current_user? @user
  end

  def admin_user
    redirect_to root_url unless current_user.admin?
  end

  def load_user
    @user = User.find_by id: params[:id]
    @user || render(file: "public/404.html", status: 404, layout: true)
  end
end
