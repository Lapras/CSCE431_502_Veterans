# frozen_string_literal: true

class StaticPagesController < ApplicationController
<<<<<<< HEAD
  layout 'not_a_member'
=======
  layout 'admin'
>>>>>>> parent of a11eba7 (first changes)
  skip_before_action :check_user_roles, only: [:not_a_member]
  def not_a_member; end

  def documentation_and_support
    # Only allow users who are NOT :not_a_member
    return unless current_user.roles.empty? || current_user.has_role?(:not_a_member)

    redirect_to root_path, alert: I18n.t('alerts.not_auth_page')
  end
end
