# frozen_string_literal: true

json.extract! management_user, :id, :email, :full_name, :uid, :avatar_url, :created_at, :updated_at
json.url management_user_url(management_user, format: :json)
