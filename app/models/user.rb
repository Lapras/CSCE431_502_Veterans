# frozen_string_literal: true

class User < ApplicationRecord
  rolify
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :omniauthable, omniauth_providers: [:google_oauth2]

  validates :email, presence: true, uniqueness: true

  def self.from_google(email:, full_name:, uid:, avatar_url:)
    create_with(uid: uid, full_name: full_name, avatar_url: avatar_url).find_or_create_by!(email: email)
  end

  def set_roles!(names)
    names = Array(names).map(&:to_s).compact_blank
    (roles.pluck(:name) - names).each { |r| remove_role(r) }
    (names - roles.pluck(:name)).each { |r| add_role(r) }
  end
end
