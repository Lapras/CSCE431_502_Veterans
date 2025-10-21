# frozen_string_literal: true

require 'securerandom'

class AddAdminUsersForGoogleOauth < ActiveRecord::Migration[7.1]
  ADMIN_EMAILS = [
    'jermurray2@tamu.edu',
    'ryanm64@tamu.edu',
    'alleny2017@tamu.edu',
    'jrt0614@tamu.edu',
    'trevorschwedler@tamu.edu',
    'paulinewade@tamu.edu',
    'riddhighate.07@tamu.edu'
  ].freeze
  def up
    return unless Rails.env.local?

    # only done in our development and testing environments

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
    return unless Rails.env.local?

    # only done in our development and testing environments

    ADMIN_EMAILS.each do |email|
      user = User.find_by(email: email)
      next unless user

      user.remove_role(:admin) if user&.has_role?(:admin)
    end
  end
end
