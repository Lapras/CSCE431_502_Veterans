json.extract! event, :id, :title, :date, :time, :location, :created_at, :updated_at
json.url event_url(event, format: :json)
