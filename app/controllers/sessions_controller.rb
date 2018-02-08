class SessionsController < ApplicationController
  before_action :load_user, only: :create
  def new; end

  def create
    if @user && @user.authenticate(params[:session][:password])
      excute_after_check_activated
    else
      flash.now[:danger] = t "sessions.create.invalid"
      render :new
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to root_url
  end

  private

  def excute_after_check_activated
    if @user.activated?
      log_in @user
      params[:session][:remember_me] == Settings.checked ? remember(@user) : forget(@user)
      redirect_back_or @user
    else
      flash[:warning] = t ".notice"
      redirect_to root_url
    end
  end

  def load_user
    @user = User.find_by email: params[:session][:email].downcase
  end
end
