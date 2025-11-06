# frozen_string_literal: true

class DashboardsController < ApplicationController
  layout :select_layout
  before_action :authenticate_user!

  def show
    # Redirect admins to admin dashboard
    if current_user.has_role?(:admin)
      redirect_to admin_dashboard_path
      return
    end
    
    # User-specific data
    @user = current_user
  end

  def select_layout
    if current_user&.has_role?(:requesting)
      'not_a_member'
    else
      'user'
    end
  end
end
