# frozen_string_literal: true

class AddTrevorAsAdmin < ActiveRecord::Migration[7.2]
  def up
    user = User.find_or_initialize_by(email: 'trevorschwedler@tamu.edu')
    user.full_name ||= 'Trevor Schwedler'
    user.uid       ||= SecureRandom.uuid
    user.avatar_url ||= ''
    user.save!(validate: false)
    user.add_role(:admin) unless user.has_role?(:admin)
  end

  def down
    user = User.find_by(email: 'trevorschwedler@tamu.edu')
    user&.remove_role(:admin) if user&.has_role?(:admin)
  end
end
