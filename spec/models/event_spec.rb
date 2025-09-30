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
end
