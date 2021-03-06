class UsersController < ApplicationController
  before_action :logged_in_user, only: %i(index edit update destroy)
  before_action :correct_user, only: [:edit, :update]
  before_action :verify_admin!, only: :destroy
  before_action :current_user, on: :show
  before_action :load_user, on: :destroy

  def index
    @users = User.activated.normal
                 .page(params[:page]).per Settings.users.per_page
  end

  def show
    @microposts = @user.microposts.recent_posts
                       .page(params[:page]).per Settings.microposts.per_page
    return if @current_user

    flash[:danger] = t ".user_not_found"
    redirect_to root_url && return unless @user.activated?
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new user_params

    if @user.save
      @user.send_activation_email
      flash[:info] = t ".plz_check_mail"
      redirect_to root_url
    else
      flash.now[:danger] = t ".failed"
      render :new
    end
  end

  def edit; end

  def update
    if @user.update_attributes user_params
      flash[:success] = t ".success"
      redirect_to @user
    else
      flash.now[:danger] = t ".failed"
      render :edit
    end
  end

  def destroy
    begin
      @user.destroy
      flash[:success] = t ".success"
    rescue StandardError
      flash[:danger] = t ".failed"
    end
    redirect_to users_url
  end

  private

  def user_params
    params.require(:user).permit :name, :email, :password,
      :password_confirmation
  end

  def correct_user
    @user = User.find_by id: params[:id]
    begin
      redirect_to root_url unless @user.current_user? current_user
    rescue StandardError
      flash[:danger] = t "url_correct_failed"
      redirect_to root_url
    end
  end

  def verify_admin!
    redirect_to root_url unless current_user.admin?
  end

  def load_user
    @user = User.find_by id: params[:id]
  end
end
