# frozen_string_literal: true

class AddAdminUsersForGoogleOauth < ActiveRecord::Migration[7.2]
  ADMIN_EMAILS = [
    'jermurray2@tamu.edu'
  ].freeze
  def up
    ADMIN_EMAILS.each do |email|
      user = User.find_or_create_by!(email: email) do |u|
      end

      user.add_role(:admin) unless user.has_role?(:admin)
    end
  end

  def down
    ADMIN_EMAILS.each do |email|
      user = User.find_by(email: email)
      user.remove_role(:admin) if user&.has_role?(:admin)
    end
  end
end
