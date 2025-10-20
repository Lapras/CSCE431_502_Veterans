# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Attendance, type: :model do
  let(:user) { User.create!(email: 'test@example.com', full_name: 'Test User') }
  let(:event) { Event.create!(title: 'Test Event', starts_at: 1.day.from_now, location: 'Test Location') }

  describe 'associations' do
    it 'belongs to user' do
      expect(described_class.reflect_on_association(:user).macro).to eq(:belongs_to)
    end

    it 'belongs to event' do
      expect(described_class.reflect_on_association(:event).macro).to eq(:belongs_to)
    end
  end

  describe 'validations' do
    it 'validates uniqueness of user_id scoped to event_id' do
      Attendance.create!(user: user, event: event, status: 'pending')
      duplicate = Attendance.new(user: user, event: event, status: 'present')

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:user_id]).to be_present
    end
  end

  describe 'enum status' do
    it 'defines pending status' do
      attendance = Attendance.new(user: user, event: event, status: 'pending')
      expect(attendance.pending?).to be true
    end

    it 'defines present status' do
      attendance = Attendance.new(user: user, event: event, status: 'present')
      expect(attendance.present?).to be true
    end

    it 'defines absent status' do
      attendance = Attendance.new(user: user, event: event, status: 'absent')
      expect(attendance.absent?).to be true
    end

    it 'defines tardy status' do
      attendance = Attendance.new(user: user, event: event, status: 'tardy')
      expect(attendance.tardy?).to be true
    end

    it 'defines excused status' do
      attendance = Attendance.new(user: user, event: event, status: 'excused')
      expect(attendance.excused?).to be true
    end
  end

  describe 'scopes' do
    before do
      @attendance1 = Attendance.create!(user: user, event: event, status: 'present')
      @attendance2 = Attendance.create!(user: User.create!(email: 'user2@example.com'), event: event, status: 'absent')
    end

    it 'filters by event with for_event scope' do
      expect(Attendance.for_event(event)).to include(@attendance1, @attendance2)
    end

    it 'filters by user with for_user scope' do
      expect(Attendance.for_user(user)).to include(@attendance1)
      expect(Attendance.for_user(user)).not_to include(@attendance2)
    end
  end

  describe '#check_in!' do
    it 'updates status to present and sets checked_in_at' do
      attendance = Attendance.create!(user: user, event: event, status: 'pending')

      freeze_time do
        attendance.check_in!

        expect(attendance.status).to eq('present')
        expect(attendance.checked_in_at).to be_within(1.second).of(Time.current)
      end
    end
  end

  describe '#mark_tardy!' do
    it 'updates status to tardy and sets checked_in_at' do
      attendance = Attendance.create!(user: user, event: event, status: 'pending')

      freeze_time do
        attendance.mark_tardy!

        expect(attendance.status).to eq('tardy')
        expect(attendance.checked_in_at).to be_within(1.second).of(Time.current)
      end
    end
  end

  describe '#point_value' do
    it 'returns 0 for present status' do
      attendance = Attendance.new(status: 'present')
      expect(attendance.point_value).to eq(0)
    end

    it 'returns 0 for excused status' do
      attendance = Attendance.new(status: 'excused')
      expect(attendance.point_value).to eq(0)
    end

    it 'returns 0.33 for tardy status' do
      attendance = Attendance.new(status: 'tardy')
      expect(attendance.point_value).to eq(0.33)
    end

    it 'returns 1 for absent status' do
      attendance = Attendance.new(status: 'absent')
      expect(attendance.point_value).to eq(1)
    end

    it 'returns 0 for pending status' do
      attendance = Attendance.new(status: 'pending')
      expect(attendance.point_value).to eq(0)
    end
  end

  describe '#status_label' do
    it 'returns humanized label for each status' do
      expect(Attendance.new(status: 'present').status_label).to eq('Present')
      expect(Attendance.new(status: 'absent').status_label).to eq('Absent')
      expect(Attendance.new(status: 'excused').status_label).to eq('Excused')
      expect(Attendance.new(status: 'tardy').status_label).to eq('Tardy')
      expect(Attendance.new(status: 'pending').status_label).to eq('Pending')
    end
  end

  describe 'STATUSES constant' do
    it 'defines all status options' do
      expect(Attendance::STATUSES.keys).to contain_exactly('pending', 'present', 'absent', 'excused', 'tardy')
    end
  end

  describe 'POINT_VALUES constant' do
    it 'defines point values for all statuses' do
      expect(Attendance::POINT_VALUES.keys).to contain_exactly('present', 'excused', 'tardy', 'absent', 'pending')
    end
  end
end
