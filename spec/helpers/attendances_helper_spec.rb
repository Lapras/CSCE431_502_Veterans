require 'rails_helper'

RSpec.describe AttendancesHelper, type: :helper do
  describe '#status_badge_class' do
    it 'returns badge-success for present' do
      expect(helper.status_badge_class('present')).to eq('badge-success')
    end

    it 'returns badge-danger for absent' do
      expect(helper.status_badge_class('absent')).to eq('badge-danger')
    end

    it 'returns badge-info for excused' do
      expect(helper.status_badge_class('excused')).to eq('badge-info')
    end

    it 'returns badge-warning for tardy' do
      expect(helper.status_badge_class('tardy')).to eq('badge-warning')
    end

    it 'returns badge-secondary for pending' do
      expect(helper.status_badge_class('pending')).to eq('badge-secondary')
    end

    it 'returns badge-secondary for unknown status' do
      expect(helper.status_badge_class('unknown')).to eq('badge-secondary')
    end
  end

  describe '#attendance_percentage' do
    let!(:member) { User.create!(email: 'member@example.com').tap { |u| u.add_role(:member) } }
    let(:event) { Event.create!(title: 'Test Event', starts_at: 1.day.from_now, location: 'Test Location') }

    it 'returns 0 when total is zero' do
      event.attendances.destroy_all
      expect(helper.attendance_percentage(event)).to eq(0)
    end

    it 'calculates percentage correctly' do
      attendance = event.attendance_for(member)
      attendance.update!(status: 'present')
      percentage = helper.attendance_percentage(event)
      expect(percentage).to eq(100.0)
    end
  end
end
