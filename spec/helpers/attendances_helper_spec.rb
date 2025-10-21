# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AttendancesHelper, type: :helper do
  describe '#status_badge_class' do
    it 'returns badge-success for present status' do
      expect(helper.status_badge_class('present')).to eq('badge-success')
    end

    it 'returns badge-danger for absent status' do
      expect(helper.status_badge_class('absent')).to eq('badge-danger')
    end

    it 'returns badge-info for excused status' do
      expect(helper.status_badge_class('excused')).to eq('badge-info')
    end

    it 'returns badge-warning for tardy status' do
      expect(helper.status_badge_class('tardy')).to eq('badge-warning')
    end

    it 'returns badge-secondary for unknown status' do
      expect(helper.status_badge_class('unknown')).to eq('badge-secondary')
    end

    it 'returns badge-secondary for nil status' do
      expect(helper.status_badge_class(nil)).to eq('badge-secondary')
    end
  end

  describe '#attendance_percentage' do
    let(:event) { instance_double('Event') }

    context 'when event has attendances' do
      it 'calculates the correct percentage' do
        allow(event).to receive(:attendance_stats).and_return({
                                                                total: 10,
                                                                present: 8,
                                                                absent: 1,
                                                                excused: 0,
                                                                tardy: 1
                                                              })

        expect(helper.attendance_percentage(event)).to eq(80.0)
      end

      it 'rounds to one decimal place' do
        allow(event).to receive(:attendance_stats).and_return({
                                                                total: 3,
                                                                present: 2,
                                                                absent: 1,
                                                                excused: 0,
                                                                tardy: 0
                                                              })

        expect(helper.attendance_percentage(event)).to eq(66.7)
      end
    end

    context 'when event has no attendances' do
      it 'returns 0' do
        allow(event).to receive(:attendance_stats).and_return({
                                                                total: 0,
                                                                present: 0,
                                                                absent: 0,
                                                                excused: 0,
                                                                tardy: 0
                                                              })

        expect(helper.attendance_percentage(event)).to eq(0)
      end
    end

    context 'when all attendances are present' do
      it 'returns 100' do
        allow(event).to receive(:attendance_stats).and_return({
                                                                total: 5,
                                                                present: 5,
                                                                absent: 0,
                                                                excused: 0,
                                                                tardy: 0
                                                              })

        expect(helper.attendance_percentage(event)).to eq(100.0)
      end
    end

    context 'when no one is present' do
      it 'returns 0' do
        allow(event).to receive(:attendance_stats).and_return({
                                                                total: 5,
                                                                present: 0,
                                                                absent: 5,
                                                                excused: 0,
                                                                tardy: 0
                                                              })

        expect(helper.attendance_percentage(event)).to eq(0.0)
      end
    end
  end
end
