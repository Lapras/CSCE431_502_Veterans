# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  before(:all) do
    RSpec::Mocks.space.proxy_for(User).reset if RSpec::Mocks.space.registered?(User)
  end

  describe 'validations' do
    it 'validates presence of email' do
      user = User.new(email: nil)
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("can't be blank")
    end
  end

  describe '.from_google' do
    let(:email) { 'user@example.com' }
    let(:full_name) { 'Test User' }
    let(:uid) { '12345' }
    let(:avatar_url) { 'http://avatar.url/image.png' }

    it 'creates a new user with given attributes if not found' do
      expect do
        User.from_google(email: email, full_name: full_name, uid: uid, avatar_url: avatar_url)
      end.to change(User, :count).by(1)

      user = User.find_by(email: email)
      expect(user.full_name).to eq(full_name)
      expect(user.uid).to eq(uid)
      expect(user.avatar_url).to eq(avatar_url)
    end

    it 'finds the existing user by email without creating new one' do
      existing_user = User.create!(email: email)
      expect do
        user = User.from_google(email: email, full_name: full_name, uid: uid, avatar_url: avatar_url)
        expect(user.id).to eq(existing_user.id)
      end.not_to change(User, :count)
    end
  end
  describe '#set_roles!' do
    let(:user) { User.create!(email: "role+#{SecureRandom.hex(6)}@ex.com") }

    before do
      # ensure no residual stubbing or doubles affect Rolify
      allow_any_instance_of(User).to receive(:roles).and_call_original
    end

    it 'removes all roles when names is nil' do
      user.add_role(:admin)
      user.add_role(:officer)
      user.set_roles!(nil)
      expect(user.roles).to be_empty
    end

    it 'normalizes strings/symbols and drops blanks' do
      user.add_role(:admin)
      user.set_roles!([:member, '', ' ', nil, 'admin'])
      expect(user.has_role?(:admin)).to be(true)
      expect(user.has_role?(:member)).to be(true)
      expect(user.has_role?(:officer)).to be(false)
    end

    it 'no-op when incoming set equals current set' do
      user.add_role(:admin)
      user.add_role(:member)
      expect {
        user.set_roles!(['member', :admin, '', 'admin'])
      }.not_to change { user.roles.pluck(:name).sort }
    end
  end

  describe 'attendance methods' do
    let(:user) { User.create!(email: 'test@example.com', full_name: 'Test User') }
    let(:event1) { Event.create!(title: 'Event 1', starts_at: 1.day.from_now, location: 'Location 1') }
    let(:event2) { Event.create!(title: 'Event 2', starts_at: 2.days.from_now, location: 'Location 2') }

    describe '#attendance_for' do
      it 'returns the attendance for the given event' do
        attendance = Attendance.create!(user: user, event: event1, status: 'present')
        expect(user.attendance_for(event1)).to eq(attendance)
      end

      it 'returns nil when no attendance exists for the event' do
        expect(user.attendance_for(event1)).to be_nil
      end
    end

    describe '#total_attendance_points' do
      it 'sums all attendance point values' do
        Attendance.create!(user: user, event: event1, status: 'present')
        Attendance.create!(user: user, event: event2, status: 'tardy')
        expect(user.total_attendance_points).to eq(0.33)
      end

      it 'returns 0 when user has no attendances' do
        expect(user.total_attendance_points).to eq(0)
      end
    end

    describe '#attendance_stats' do
      before do
        Attendance.create!(user: user, event: event1, status: 'present')
        Attendance.create!(user: user, event: event2, status: 'absent')
      end

      it 'returns a hash with attendance statistics' do
        stats = user.attendance_stats
        expect(stats[:total_events]).to eq(2)
        expect(stats[:present]).to eq(1)
        expect(stats[:absent]).to eq(1)
        expect(stats[:excused]).to eq(0)
        expect(stats[:tardy]).to eq(0)
        expect(stats[:points]).to eq(1)
      end
    end
  end
end
