# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :check_user_roles

  # Nescessary check so that unroled users are sent to the not_a_member_path
  def check_user_roles
    return unless current_user # Only check if logged in
    return if on_not_a_member_page? || on_auth_pages? || on_membership_request_pages?

    return unless current_user.roles.empty? && !on_not_a_member_page?

    redirect_to not_a_member_path, alert: I18n.t('alerts.not_a_member')
  end

  def on_not_a_member_page?
    controller_name == 'static_pages' && action_name == 'not_a_member'
  end

  def on_membership_request_pages?
    controller_name == 'membership_requests' && action_name == 'create'
  end

  def on_auth_pages?
    devise_controller?
  end

  def require_role!(*roles)
    return if current_user && roles.any? { |r| current_user.has_role?(r) }

    redirect_to root_path, alert: I18n.t('alerts.not_authorized')
  end
end
