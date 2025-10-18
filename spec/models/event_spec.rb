# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Event, type: :model do
  context 'validations' do
    it 'is valid with valid attributes' do
      event = Event.new(title: 'Concert', starts_at: 1.hour.from_now, location: 'London')
      expect(event).to be_valid
    end

    it 'is invalid without a title' do
      event = Event.new(title: nil, starts_at: 1.hour.from_now, location: 'London')
      event.valid?
      expect(event.errors[:title]).to include("can't be blank")
    end

    it 'is invalid without a starts_at' do
      event = Event.new(title: 'Concert', starts_at: nil, location: 'London')
      event.valid?
      expect(event.errors[:starts_at]).to include("can't be blank")
    end

    it 'is invalid without a location' do
      event = Event.new(title: 'Concert', starts_at: 1.hour.from_now, location: nil)
      event.valid?
      expect(event.errors[:location]).to include("can't be blank")
    end

    it 'is invalid if starts_at is in the past' do
      event = Event.new(title: 'Concert', starts_at: 1.hour.ago, location: 'London')
      event.valid?
      expect(event.errors[:starts_at]).to include("can't be in the past")
    end
  end
  describe 'custom validations on starts_at' do
    it 'returns early when starts_at is blank (presence error, but custom no extra error)' do
      e = Event.new(title: 'T', location: 'Gym', starts_at: nil)
      e.valid?
      # presence validator adds an error, but the custom "past" validator returned early
      expect(e.errors[:starts_at]).to include("can't be blank")
      # Ensure it did NOT add the "past" message in this branch
      expect(e.errors[:starts_at].grep(/can't be in the past/)).to be_empty
    end

    it 'accepts an ActiveSupport::TimeWithZone' do
      e = Event.new(title: 'T', location: 'Gym', starts_at: Time.zone.now + 10.minutes)
      expect(e).to be_valid
    end

    it "adds 'is not a valid datetime' when starts_at is present but not a Time/TimeWithZone" do
      e = Event.new(title: 'T', location: 'Gym')
      # Call ONLY the datetime validator so we don't hit the 'past' validator
      allow(e).to receive(:starts_at).and_return(Object.new) # present?, wrong type
      e.send(:starts_at_must_be_valid_datetime)
      expect(e.errors[:starts_at]).to include('is not a valid datetime')
    end
  end
  describe 'private validator: starts_at_must_be_valid_datetime (direct call)' do
    it "adds 'is not a valid datetime' with a non-time object" do
      e = Event.new(title: 'T', location: 'Gym')
      allow(e).to receive(:starts_at).and_return(Object.new)
      e.send(:starts_at_must_be_valid_datetime)
      expect(e.errors[:starts_at]).to include('is not a valid datetime')
    end
  end
end
