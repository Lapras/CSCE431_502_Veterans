module EventsHelper
  def formatted_event_date(event)
    event.starts_at.strftime("%Y-%m-%d %H:%M:%S %Z") if event.starts_at.present?
  end
end
