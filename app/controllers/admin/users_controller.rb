# frozen_string_literal: true

module Admin
  class UsersController < BaseController
    # GET /admin/users or /admin/users.json
    def index
      # In order to filter results, we're getting parameters from the HTTP request
      @include_all = params[:include_all] == 'true'

      @users = if @include_all
                 User.all
               else
                 User.includes(:roles)
                     .where.not(id: User.without_roles_or_requesting.select(:id))
               end
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
        if names&.include?('none')
          # Special case: 'none' means clear all roles
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

    # GET /admin/users/1/confirm_delete
    def confirm_delete; end

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
      return if names.nil? || names.compact_blank.empty?

      user.set_roles!(names.compact_blank)
    end

    def incoming_role_names
      raw = params.dig(:user, :role_names)
      return nil if raw.nil? # key missing

      Array(raw).compact_blank
    end

    def require_admin!
      redirect_to root_path, alert: t('admin.users.unauthorized') unless current_user&.has_role?(:admin)
    end
  end
end
