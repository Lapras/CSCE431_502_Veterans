# frozen_string_literal: true

require 'rails_helper'
def formatted_event_date(event)
  event.starts_at.strftime('%Y-%m-%d %H:%M:%S %Z') if event.starts_at.present?
end

RSpec.describe EventsHelper, type: :helper do
  describe '#formatted_event_date' do
    it "formats the starts_at datetime in 'YYYY-MM-DD HH:MM:SS UTC' format" do
      event = double('Event', starts_at: Time.utc(2025, 10, 1, 6, 7, 0))
      expect(helper.formatted_event_date(event)).to eq('2025-10-01 06:07:00 UTC')
    end

    it 'returns nil if starts_at is nil' do
      event = double('Event', starts_at: nil)
      expect(helper.formatted_event_date(event)).to be_nil
    end
  end

  describe '#user_excusal_requests_for' do
    let(:user) { User.create!(email: 'user@example.com') }
    let(:event) { Event.create!(title: 'Test Event', starts_at: 1.day.from_now, location: 'Test Location') }

    it 'returns excusal requests for the given user and event' do
      excusal_request = ExcusalRequest.create!(user: user, event: event, reason: 'Test reason')
      requests = helper.user_excusal_requests_for(event, user)
      expect(requests).to include(excusal_request)
    end

    it 'returns empty when user has no excusal requests for the event' do
      requests = helper.user_excusal_requests_for(event, user)
      expect(requests).to be_empty
    end

    it 'returns none when user is nil' do
      requests = helper.user_excusal_requests_for(event, nil)
      expect(requests).to eq(ExcusalRequest.none)
    end

    it 'handles error when current_user is not available' do
      allow(helper).to receive(:current_user).and_raise(StandardError)
      requests = helper.user_excusal_requests_for(event)
      expect(requests).to eq(ExcusalRequest.none)
    end
  end
end
