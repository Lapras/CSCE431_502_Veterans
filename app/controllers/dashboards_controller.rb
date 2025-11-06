# frozen_string_literal: true

class DashboardsController < ApplicationController
  layout 'user'
  before_action :authenticate_user!

  def show
    # Redirect admins to admin dashboard
    if current_user.has_role?(:admin) || current_user.has_role?(:officer)
      redirect_to management_dashboard_path
      return
    end

    # User-specific data
    @user = current_user
  end
end
