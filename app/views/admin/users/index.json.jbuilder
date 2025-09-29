# frozen_string_literal: true

json.array! @users do |user|
  json.extract! user, :id, :full_name, :email, :uid, :avatar_url
  json.roles user.roles.pluck(:name)
  json.url admin_user_url(user, format: :json)
end
