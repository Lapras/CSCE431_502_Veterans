# frozen_string_literal: true

module EventsHelper
  def formatted_event_date(event)
    return nil unless event&.starts_at
    event.starts_at.utc.strftime('%Y-%m-%d %H:%M:%S UTC')
  end
  def user_excusal_requests_for(event, user = nil)
    u = user
    unless u
      u = begin
        current_user
      rescue StandardError
        nil
      end
    end

    return ExcusalRequest.none unless u && u.respond_to?(:excusal_requests)
    u.excusal_requests.where(event_id: event.id)
  end
end
