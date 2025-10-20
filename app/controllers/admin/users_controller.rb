# frozen_string_literal: true

module Admin
  class UsersController < ApplicationController
    layout 'admin'
    before_action :authenticate_user!
    before_action :require_admin!
    before_action :set_user, only: %i[show edit update destroy]

    # GET /admin/users or /admin/users.json
    def index
      @users = User.includes(:roles).order(:full_name, :email)
    end

    # GET /admin/users/1 or /admin/users/1.json
    def show; end

    # GET /admin/users/new
    def new
      @user = User.new
    end

    # GET /admin/users/1/edit
    def edit; end

    # POST /admin/users or /admin/users.json
    def create
      @user = User.new(user_params.except(:role_names))
      if @user.save
        names = incoming_role_names
        if names&.any?
          names.each { |r| Role.find_or_create_by!(name: r) }
          @user.set_roles!(names)
        end
        redirect_to [:admin, @user], notice: t('admin.users.created')
      else
        render :new, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /admin/users/1 or /admin/users/1.json
    def update
      if @user.update(user_params.except(:role_names))
        names = incoming_role_names
        # IMPORTANT: do nothing if role_names param is missing OR blank (keeps existing roles)
        # Special case: if 'none' is provided, clear all roles
        if names&.include?('none')
          @user.roles = []
        elsif names&.any?
          names.each { |r| Role.find_or_create_by!(name: r) }
          @user.set_roles!(names)
        end
        redirect_to [:admin, @user], notice: t('admin.users.updated')
      else
        render :edit, status: :unprocessable_entity
      end
    end

    # DELETE /admin/users/1 or /admin/users/1.json
    def destroy
      @user.destroy!

      redirect_to admin_users_path, notice: t('admin.users.deleted')
    end

    private

    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def user_params
      params.require(:user).permit(:email, :full_name, :uid, :avatar_url, role_names: [])
    end

    def update_roles(user)
      names = params.dig(:user, :role_names)
      return if names.nil? || names.reject(&:blank?).empty?

      user.set_roles!(names.reject(&:blank?))
    end

    def incoming_role_names
      raw = params.dig(:user, :role_names)
      return nil if raw.nil? # key missing

      Array(raw).reject(&:blank?)
    end

    def require_admin!
      redirect_to root_path, alert: t('admin.users.unauthorized') unless current_user&.has_role?(:admin)
    end
  end
end
