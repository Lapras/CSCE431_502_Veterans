require 'rails_helper'

RSpec.describe Attendance, type: :model do
  let(:user) { User.create!(email: 'test@example.com', full_name: 'Test User') }
  let(:user2) { User.create!(email: 'user2@example.com', full_name: 'User 2') }

  describe 'associations' do
    it 'belongs to user' do
      user.add_role(:member)
      event = Event.create!(title: 'Test Event', starts_at: 1.day.from_now, location: 'Test Location')
      attendance = event.attendance_for(user)
      expect(attendance.user).to eq(user)
    end

    it 'belongs to event' do
      user.add_role(:member)
      event = Event.create!(title: 'Test Event', starts_at: 1.day.from_now, location: 'Test Location')
      attendance = event.attendance_for(user)
      expect(attendance.event).to eq(event)
    end
  end

  describe 'validations' do
    it 'validates uniqueness of user_id scoped to event_id' do
      user.add_role(:member)
      event = Event.create!(title: 'Test Event', starts_at: 1.day.from_now, location: 'Test Location')
      # after_create already created attendance for user
      duplicate = Attendance.new(user: user, event: event, status: 'present')

      expect(duplicate.valid?).to be false
      expect(duplicate.errors[:user_id]).to include('already has an attendance record for this event')
    end

    it 'allows same user to have attendance for different events' do
      user.add_role(:member)
      event1 = Event.create!(title: 'Event 1', starts_at: 1.day.from_now, location: 'Location 1')
      event2 = Event.create!(title: 'Event 2', starts_at: 2.days.from_now, location: 'Location 2')

      attendance1 = event1.attendance_for(user)
      attendance2 = event2.attendance_for(user)

      expect(attendance1).not_to be_nil
      expect(attendance2).not_to be_nil
      expect(attendance1.event).to eq(event1)
      expect(attendance2.event).to eq(event2)
    end
  end

  describe 'enums' do
    it 'defines status enum' do
      user.add_role(:member)
      event = Event.create!(title: 'Test Event', starts_at: 1.day.from_now, location: 'Test Location')
      attendance = event.attendance_for(user)

      expect(attendance.pending?).to be true
      attendance.update!(status: 'present')
      expect(attendance.present?).to be true
      expect(attendance.pending?).to be false
    end
  end

  describe 'scopes' do
    before do
      user.add_role(:member)
      user2.add_role(:member)

      @event1 = Event.create!(title: 'Event 1', starts_at: 1.day.from_now, location: 'Location 1')
      @event2 = Event.create!(title: 'Event 2', starts_at: 2.days.from_now, location: 'Location 2')

      @attendance1 = @event1.attendance_for(user)
      @attendance2 = @event1.attendance_for(user2)
      @attendance3 = @event2.attendance_for(user)

      @attendance1.update!(status: 'present')
      @attendance2.update!(status: 'absent')
      @attendance3.update!(status: 'pending')
    end

    it 'filters by event' do
      attendances = Attendance.for_event(@event1)
      expect(attendances).to include(@attendance1, @attendance2)
      expect(attendances).not_to include(@attendance3)
    end

    it 'filters by user' do
      attendances = Attendance.for_user(user)
      expect(attendances).to include(@attendance1, @attendance3)
      expect(attendances).not_to include(@attendance2)
    end
  end

  describe '#check_in!' do
    it 'updates status to present and sets checked_in_at' do
      user.add_role(:member)
      event = Event.create!(title: 'Test Event', starts_at: 1.day.from_now, location: 'Test Location')
      attendance = event.attendance_for(user)

      expect {
        attendance.check_in!
      }.to change { attendance.status }.from('pending').to('present')

      expect(attendance.checked_in_at).not_to be_nil
    end
  end

  describe '#mark_tardy!' do
    it 'updates status to tardy and sets checked_in_at' do
      user.add_role(:member)
      event = Event.create!(title: 'Test Event', starts_at: 1.day.from_now, location: 'Test Location')
      attendance = event.attendance_for(user)

      expect {
        attendance.mark_tardy!
      }.to change { attendance.status }.from('pending').to('tardy')

      expect(attendance.checked_in_at).not_to be_nil
    end
  end

  describe '#point_value' do
    let(:event) { Event.create!(title: 'Test Event', starts_at: 1.day.from_now, location: 'Test Location') }

    before do
      user.add_role(:member)
    end

    it 'returns 0 for present' do
      attendance = event.attendance_for(user)
      attendance.update!(status: 'present')
      expect(attendance.point_value).to eq(0)
    end

    it 'returns 0 for excused' do
      attendance = event.attendance_for(user)
      attendance.update!(status: 'excused')
      expect(attendance.point_value).to eq(0)
    end

    it 'returns 0.33 for tardy' do
      attendance = event.attendance_for(user)
      attendance.update!(status: 'tardy')
      expect(attendance.point_value).to eq(0.33)
    end

    it 'returns 1 for absent' do
      attendance = event.attendance_for(user)
      attendance.update!(status: 'absent')
      expect(attendance.point_value).to eq(1)
    end

    it 'returns 0 for pending' do
      attendance = event.attendance_for(user)
      expect(attendance.point_value).to eq(0)
    end
  end

  describe '#status_label' do
    it 'returns human readable status' do
      user.add_role(:member)
      event = Event.create!(title: 'Test Event', starts_at: 1.day.from_now, location: 'Test Location')
      attendance = event.attendance_for(user)

      attendance.update!(status: 'present')
      expect(attendance.status_label).to eq('Present')

      attendance.update!(status: 'absent')
      expect(attendance.status_label).to eq('Absent')

      attendance.update!(status: 'tardy')
      expect(attendance.status_label).to eq('Tardy')

      attendance.update!(status: 'excused')
      expect(attendance.status_label).to eq('Excused')

      attendance.update!(status: 'pending')
      expect(attendance.status_label).to eq('Pending')
    end
  end
end
