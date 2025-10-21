# frozen_string_literal: true

module Admin
  class MembershipRequestsController < ApplicationController
    before_action :require_admin!

    # puts admin layout (left handed sidebar)
    layout 'admin'

    def index
      @users = User.with_role(:requesting)
    end

    def approve
      user = User.find(params[:id])
      user.remove_role(:requesting)
      user.add_role(:member)
      redirect_to admin_membership_requests_path, notice: "#{user.email} has been approved."
    end

    def deny
      user = User.find(params[:id])
      user.remove_role(:requesting)
      redirect_to admin_membership_requests_path, notice: "#{user.email} has been denied."
    end

    private

    def require_admin!
      return if current_user.has_role?(:admin)

      redirect_to root_path, alert: I18n.t('alerts.not_authorized')
    end
  end
end
