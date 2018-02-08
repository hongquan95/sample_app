class PasswordResetsController < ApplicationController
  before_action :load_user, only: %i(edit update)
  before_action :valid_user, only: %i(edit update)
  before_action :check_expiration, only: %i(edit update) # Case (1)

  def new; end

  def create
    @user = User.find_by email: params[:password_reset][:email].downcase
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = t ".notice"
      redirect_to root_url
    else
      flash.now[:danger] = t ".notfound"
      render :new
    end
  end

  def edit; end

  def update
    if params[:user][:password].blank? # Case (3)
      @user.errors.add :password, t(".case3")
      render :edit
    elsif @user.update_attributes user_params # Case (4)
      log_in @user
      @user.update_attribute :reset_digest, nil
      flash[:success] = t ".case4"
      redirect_to @user
    else
      render :edit # Case (2)
    end
  end

  private

  def user_params
    params.require(:user).permit :password, :password_confirmation
  end

  def load_user
    @user = User.find_by email: params[:email]
  end

  # Confirms a valid user.
  def valid_user
    redirect_to root_url unless @user && @user.activated? && @user.authenticated?(:reset, params[:id])
  end

  def check_expiration
    if @user.password_reset_expired?
      flash[:danger] = t ".expired"
      redirect_to new_password_reset_url
    end
  end
end
