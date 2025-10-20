require 'rails_helper'

RSpec.describe "Attendances", type: :request do
  let(:admin) { User.create!(email: 'admin@example.com', full_name: 'Admin User') }
  let(:member) { User.create!(email: 'member@example.com', full_name: 'Member User') }
  let(:event) { Event.create!(title: 'Test Event', starts_at: 1.day.from_now, location: 'Test Location') }

  before do
    admin.add_role(:admin)
    member.add_role(:member)
  end

  describe "GET /events/:event_id/attendances" do
    context "as admin" do
      before do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(admin)
        allow_any_instance_of(ApplicationController).to receive(:authenticate_user!).and_return(true)
        allow_any_instance_of(ApplicationController).to receive(:check_user_roles).and_return(true)
      end

      it "returns success" do
        get event_attendances_path(event)
        expect(response).to be_successful
      end
    end

    context "as member" do
      before do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(member)
        allow_any_instance_of(ApplicationController).to receive(:authenticate_user!).and_return(true)
        allow_any_instance_of(ApplicationController).to receive(:check_user_roles).and_return(true)
      end

      it "redirects to events path" do
        get event_attendances_path(event)
        expect(response).to redirect_to(events_path)
      end
    end
  end

  describe "POST /events/:event_id/attendances/check_in" do
    before do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(member)
      allow_any_instance_of(ApplicationController).to receive(:authenticate_user!).and_return(true)
      allow_any_instance_of(ApplicationController).to receive(:check_user_roles).and_return(true)
    end

    it "checks in the user" do
      attendance = event.attendance_for(member)
      expect(attendance.status).to eq('pending')

      post check_in_event_attendances_path(event)

      attendance.reload
      expect(attendance.status).to eq('present')
      expect(response).to redirect_to(event)
    end

    it "creates attendance if it doesn't exist" do
      # Remove the automatically created attendance
      event.attendances.where(user: member).destroy_all

      expect {
        post check_in_event_attendances_path(event)
      }.to change { event.attendances.count }.by(1)

      expect(response).to redirect_to(event)
    end
  end

  describe "POST /events/:event_id/attendances/bulk_update" do
    before do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(admin)
      allow_any_instance_of(ApplicationController).to receive(:authenticate_user!).and_return(true)
      allow_any_instance_of(ApplicationController).to receive(:check_user_roles).and_return(true)
    end

    it "updates multiple attendances" do
      # Ensure event has attendance records
      attendance1 = event.attendances.find_or_create_by!(user: admin, status: 'pending')
      attendance2 = event.attendances.find_or_create_by!(user: member, status: 'pending')

      post bulk_update_event_attendances_path(event), params: {
        attendances: {
          attendance1.id.to_s => { status: 'present' },
          attendance2.id.to_s => { status: 'absent' }
        }
      }

      attendance1.reload
      attendance2.reload

      expect(attendance1.status).to eq('present')
      expect(attendance2.status).to eq('absent')
      expect(response).to redirect_to(event_attendances_path(event))
    end
  end
end
