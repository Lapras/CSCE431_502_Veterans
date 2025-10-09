# frozen_string_literal: true

class MembershipRequestsController < ApplicationController
  def create
    if current_user.has_role?(:member)
      redirect_to root_path, alert: I18n.t('alerts.already_member')
    elsif current_user.has_role?(:requesting)
      redirect_to root_path, alert: I18n.t('alerts.already_requesting')
    else
      current_user.add_role(:requesting)
      redirect_to root_path, notice: I18n.t('membership.request_send')
    end
  end
end
