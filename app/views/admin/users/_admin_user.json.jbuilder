# frozen_string_literal: true

json.extract! admin_user, :id, :email, :full_name, :uid, :avatar_url, :created_at, :updated_at
json.url admin_user_url(admin_user, format: :json)
