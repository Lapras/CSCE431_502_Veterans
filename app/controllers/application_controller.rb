# frozen_string_literal: true

class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  before_action :authenticate_user!
  before_action :check_user_roles

  # Nescessary check so that unroled users are sent to the not_a_member_path
  def check_user_roles
    return unless current_user # Only check if logged in
    return if on_not_a_member_page? || on_auth_pages?

    return unless current_user.roles.empty? && !on_not_a_member_page?

    redirect_to not_a_member_path, alert: I18n.t('alerts.not_a_member')
  end

  def on_not_a_member_page?
    controller_name == 'static_pages' && action_name == 'not_a_member'
  end

  def on_auth_pages?
    devise_controller?
  end
end
