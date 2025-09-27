class Admin::UsersController < ApplicationController
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
    @admin_user = Admin::User.new
  end

  # GET /admin/users/1/edit
  def edit
  end

  # POST /admin/users or /admin/users.json
  def create
    @admin_user = Admin::User.new(admin_user_params)

    respond_to do |format|
      if @admin_user.save
        format.html { redirect_to @admin_user, notice: "User was successfully created." }
        format.json { render :show, status: :created, location: @admin_user }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @admin_user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/users/1 or /admin/users/1.json
  def update
    respond_to do |format|
      if @admin_user.update(admin_user_params)
        format.html { redirect_to @admin_user, notice: "User was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @admin_user }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @admin_user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/users/1 or /admin/users/1.json
  def destroy
    @admin_user.destroy!

    respond_to do |format|
      format.html { redirect_to admin_users_path, notice: "User was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def admin_user_params
      params.require(:admin_user).permit(:email, :full_name, :uid, :avatar_url)
    end

    def require_admin!
      redirect_to root_path, alert: "Unauthorized" unless current_user&.has_role?(:admin)
    end

end
