# frozen_string_literal: true

class MembershipRequestsController < ApplicationController
  def create
    if current_user.has_role?(:member)
      redirect_to root_path, alert: 'You are already a member.'
    elsif current_user.has_role?(:requesting)
      redirect_to root_path, alert: 'You have already requested membership.'
    else
      current_user.add_role(:requesting)
      redirect_to root_path, notice: 'Your membership request has been submitted.'
    end
  end
end
