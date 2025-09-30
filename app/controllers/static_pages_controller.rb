# frozen_string_literal: true

class StaticPagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:not_a_member]
  skip_before_action :check_user_roles, only: [:not_a_member]
  def not_a_member; end
end
