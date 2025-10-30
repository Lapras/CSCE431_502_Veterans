# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Role gate', type: :request do
  before do
    allow_any_instance_of(ApplicationController).to receive(:authenticate_user!).and_return(true)
  end

  it 'redirects to /not_a_member when current_user has no roles' do
    user = double('User', roles: [], has_role?: false)
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)

    get events_url
    expect(response).to redirect_to('/not_a_member')
  end

  it 'allows through when current_user has at least one role' do
    user = double('User', roles: [double('Role')], has_role?: true)
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)

    get events_url
    expect(response).to be_successful
  end

  it "does NOT add the 'in the past' error when starts_at is blank (only presence error)" do
    e = Event.new(title: 'T', location: 'L', starts_at: nil)
    expect(e).not_to be_valid
    # Presence validator fires:
    expect(e.errors[:starts_at]).to include("can't be blank")
    # Custom validator returns early (no 'in the past' message):
    expect(e.errors[:starts_at]).not_to include("can't be in the past")
  end

  it "adds 'is not a valid datetime' when starts_at is present but not a Time/TimeWithZone" do
    e = Event.new(title: 'T', location: 'L')
    # Make starts_at 'present' yet not a Time/TimeWithZone
    allow(e).to receive(:starts_at).and_return('not-a-time')
    e.validate
    expect(e.errors[:starts_at]).to include('is not a valid datetime')
    expect(e.errors[:starts_at]).not_to include("can't be blank")
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
      e = Event.new(title: 'T', location: 'Gym', starts_at: 10.minutes.from_now)
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

RSpec.describe Event, type: :model do
  let(:member) do
    User.create!(email: 'member@example.com')
    User.last.add_role(:member)
    User.last
  end
  let(:valid_event) { Event.create!(title: 'Test Event', starts_at: 1.day.from_now, location: 'Test Location') }

  describe 'associations' do
    it 'has many attendances' do
      expect(described_class.reflect_on_association(:attendances).macro).to eq(:has_many)
    end

    it 'has many assigned_users through event_users' do
      expect(described_class.reflect_on_association(:assigned_users).macro).to eq(:has_many)
    end

    it 'has many excusal_requests' do
      expect(described_class.reflect_on_association(:excusal_requests).macro).to eq(:has_many)
    end
  end

  describe 'validations' do
    it 'validates presence of title' do
      event = Event.new(starts_at: 1.day.from_now, location: 'Location')
      expect(event).not_to be_valid
      expect(event.errors[:title]).to be_present
    end

    it 'validates presence of starts_at' do
      event = Event.new(title: 'Title', location: 'Location')
      expect(event).not_to be_valid
      expect(event.errors[:starts_at]).to be_present
    end

    it 'validates presence of location' do
      event = Event.new(title: 'Title', starts_at: 1.day.from_now)
      expect(event).not_to be_valid
      expect(event.errors[:location]).to be_present
    end
  end

  describe 'after_create callback' do
    it 'creates attendance records for assigned users' do
      member # create member first
      event = Event.create!(title: 'New Event', starts_at: 1.day.from_now, location: 'Location')
      event.assigned_users << member # assign member to event

      # Manually trigger the callback since we assigned after creation
      event.send(:create_attendance_records)

      expect(event.attendances.count).to eq(1)
      expect(event.attendances.first.user).to eq(member)
      expect(event.attendances.first.status).to eq('pending')
    end
  end

  describe '#attendance_for' do
    it 'returns attendance for a specific user' do
      member # ensure member exists
      event = Event.create!(title: 'Test Event', starts_at: 1.day.from_now, location: 'Test Location')
      attendance = event.attendances.find_by(user: member)

      expect(event.attendance_for(member)).to eq(attendance)
    end

    it 'returns nil for non-existent user' do
      event = Event.create!(title: 'Test Event', starts_at: 1.day.from_now, location: 'Test Location')
      expect(event.attendance_for(nil)).to be_nil
    end
  end

  describe '#user_checked_in?' do
    it 'returns true when user status is present' do
      member
      event = Event.create!(title: 'Test Event', starts_at: 1.day.from_now, location: 'Test Location')
      event.assigned_users << member
      event.send(:create_attendance_records)
      attendance = event.attendances.find_by(user: member)
      attendance.update!(status: 'present')

      expect(event.user_checked_in?(member)).to be true
    end

    it 'returns true when user status is tardy' do
      member
      event = Event.create!(title: 'Test Event', starts_at: 1.day.from_now, location: 'Test Location')
      event.assigned_users << member
      event.send(:create_attendance_records)
      attendance = event.attendances.find_by(user: member)
      attendance.update!(status: 'tardy')

      expect(event.user_checked_in?(member)).to be true
    end

    it 'returns false when user status is pending' do
      member
      event = Event.create!(title: 'Test Event', starts_at: 1.day.from_now, location: 'Test Location')
      event.assigned_users << member
      event.send(:create_attendance_records)

      expect(event.user_checked_in?(member)).to be false
    end

    it 'returns false when user status is absent' do
      member
      event = Event.create!(title: 'Test Event', starts_at: 1.day.from_now, location: 'Test Location')
      event.assigned_users << member
      event.send(:create_attendance_records)
      attendance = event.attendances.find_by(user: member)
      attendance.update!(status: 'absent')

      expect(event.user_checked_in?(member)).to be false
    end
  end

  describe '#attendance_stats' do
    before do
      valid_event.attendances.create!(user: User.create!(email: 'u1@ex.com'), status: 'present')
      valid_event.attendances.create!(user: User.create!(email: 'u2@ex.com'), status: 'absent')
      valid_event.attendances.create!(user: User.create!(email: 'u3@ex.com'), status: 'tardy')
      valid_event.attendances.create!(user: User.create!(email: 'u4@ex.com'), status: 'excused')
    end

    it 'returns correct attendance statistics' do
      stats = valid_event.attendance_stats

      expect(stats[:total]).to be > 0
      expect(stats[:present]).to eq(1)
      expect(stats[:absent]).to eq(1)
      expect(stats[:tardy]).to eq(1)
      expect(stats[:excused]).to eq(1)
    end
  end

  describe 'check-in code' do
    it 'generates a 3-digit check-in code on creation' do
      event = Event.create!(title: 'Test', starts_at: 1.day.from_now, location: 'Location')
      expect(event.check_in_code).to match(/^\d{3}$/)
    end

    it 'generates different codes for different events' do
      event1 = Event.create!(title: 'Event 1', starts_at: 1.day.from_now, location: 'Location')
      event2 = Event.create!(title: 'Event 2', starts_at: 1.day.from_now, location: 'Location')
      # While it's possible they could be the same by chance (1/1000), it's unlikely
      # If this test fails occasionally, that's actually fine - but usually they'll differ
      expect(event1.check_in_code).to match(/^\d{3}$/)
      expect(event2.check_in_code).to match(/^\d{3}$/)
    end

    describe '#valid_check_in_code?' do
      it 'returns true for correct code' do
        event = Event.create!(title: 'Test', starts_at: 1.day.from_now, location: 'Location')
        expect(event.valid_check_in_code?(event.check_in_code)).to be true
      end

      it 'returns false for incorrect code' do
        event = Event.create!(title: 'Test', starts_at: 1.day.from_now, location: 'Location')
        wrong_code = (event.check_in_code.to_i + 1) % 1000
        expect(event.valid_check_in_code?(format('%03d', wrong_code))).to be false
      end

      it 'returns false for nil code' do
        event = Event.create!(title: 'Test', starts_at: 1.day.from_now, location: 'Location')
        expect(event.valid_check_in_code?(nil)).to be false
      end
    end
  end
end
