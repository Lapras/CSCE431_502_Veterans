# frozen_string_literal: true

class StaticPagesController < ApplicationController
  skip_before_action :check_user_roles, only: [:not_a_member]
  def not_a_member; end

  def documentation_and_support
    # Only allow users who are NOT :not_a_member
    if current_user.roles.empty? || current_user.has_role?(:not_a_member)
      redirect_to root_path, alert: "You are not authorized to view this page."
    end
  end
end
