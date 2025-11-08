# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :authenticate_user!
  layout :select_layout

  def profile
    @user = current_user
  end

  private

  def select_layout
    current_user&.has_role?(:admin) ? 'admin' : 'user'
  end
end
