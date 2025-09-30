# frozen_string_literal: true

require 'securerandom'

class AddAdminUsersForGoogleOauth < ActiveRecord::Migration[7.2]
  ADMIN_EMAILS = [
    'jermurray2@tamu.edu'
  ].freeze
  def up
    ADMIN_EMAILS.each do |email|
      User.find_or_create_by!(email: email)
      user = User.find_or_initialize_by(email: email)
      user.full_name ||= 'Seed Admin'
      user.uid       ||= SecureRandom.uuid
      user.avatar_url ||= ''

      user.save!(validate: false)

      user.add_role(:admin) unless user.has_role?(:admin)
    end
  end

  def down
    ADMIN_EMAILS.each do |email|
      user = User.find_by(email: email)
      next unless user

      user.remove_role(:admin) if user&.has_role?(:admin)
    end
  end
end
