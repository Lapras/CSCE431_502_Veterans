# frozen_string_literal: true

json.extract! event, :id, :title, :starts_at, :location, :created_at, :updated_at
json.url event_url(event, format: :json)
