require 'rails_helper'
def formatted_event_date(event)
  event.starts_at.strftime("%Y-%m-%d %H:%M:%S %Z") if event.starts_at.present?
end

RSpec.describe EventsHelper, type: :helper do
  describe "#formatted_event_date" do
    it "formats the starts_at datetime in 'YYYY-MM-DD HH:MM:SS UTC' format" do
      event = double('Event', starts_at: Time.utc(2025, 10, 1, 6, 7, 0))
      expect(helper.formatted_event_date(event)).to eq("2025-10-01 06:07:00 UTC")
    end

    it "returns nil if starts_at is nil" do
      event = double('Event', starts_at: nil)
      expect(helper.formatted_event_date(event)).to be_nil
    end
  end
end
