class Admin::UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin!
  before_action :set_user, only: %i[ show edit update destroy ]

  # GET /admin/users or /admin/users.json
  def index
    @users = User.includes(:roles).order(:full_name, :email)
  end

  # GET /admin/users/1 or /admin/users/1.json
  def show
  end

  # GET /admin/users/new
  def new
    @user = User.new
  end

  # GET /admin/users/1/edit
  def edit
  end

  # POST /admin/users or /admin/users.json
  def create
    @user = User.new(user_params)
    if @user.save
      update_roles(@user)
      redirect_to [:admin, @user], notice: "User created"
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /admin/users/1 or /admin/users/1.json
  def update
    if @user.update(user_params)
      update_roles(@user)
      redirect_to [:admin, @user], notice: "User updated"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /admin/users/1 or /admin/users/1.json
  def destroy
    @user.destroy!

    redirect_to admin_users_path, notice: "User deleted"
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def user_params
      params.require(:user).permit(:email, :full_name, :uid, :avatar_url)
    end

    def update_roles(user)
      return unless params.dig(:user, :role_names).present?
      user.roles = []
      params[:user][:role_names].reject(&:blank?).each {|r| user.add_role(r)}
    end

    def require_admin!
      redirect_to root_path, alert: "Unauthorized" unless current_user&.has_role?(:admin)
    end

end
