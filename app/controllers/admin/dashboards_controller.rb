# frozen_string_literal: true

module Admin
  class DashboardsController < ApplicationController
    layout 'admin'
    before_action :authenticate_user!
    before_action :require_admin!

    def show
      @total_users = User.count
      @admin_users = User.with_role(:admin)
      @member_users = User.with_role(:member)
      @recent_users = User.order(created_at: :desc).limit(10)
    end

    private

    def require_admin!
      redirect_to root_path, alert: t('admin.users.unauthorized') unless current_user&.has_role?(:admin)
    end
  end
end
