require 'rails_helper'

RSpec.describe "Admin::AttendanceReports", type: :request do
  let(:admin) { User.create!(email: 'admin@example.com', full_name: 'Admin User') }
  let(:member) { User.create!(email: 'member@example.com', full_name: 'Member User') }

  before do
    admin.add_role(:admin)
    member.add_role(:member)
  end

  describe "GET /admin/attendance_reports" do
    context "as admin" do
      before do
        sign_in admin
      end

      it "returns success" do
        get admin_attendance_reports_path
        expect(response).to be_successful
      end

      it "filters by query parameter" do
        get admin_attendance_reports_path, params: { q: 'Admin' }
        expect(response).to be_successful
      end

      it "sorts by name" do
        get admin_attendance_reports_path, params: { sort: 'name', dir: 'asc' }
        expect(response).to be_successful
      end

      it "sorts by email" do
        get admin_attendance_reports_path, params: { sort: 'email', dir: 'desc' }
        expect(response).to be_successful
      end

      it "sorts by present count" do
        get admin_attendance_reports_path, params: { sort: 'present', dir: 'asc' }
        expect(response).to be_successful
      end

      it "sorts by absent count" do
        get admin_attendance_reports_path, params: { sort: 'absent', dir: 'desc' }
        expect(response).to be_successful
      end

      it "sorts by tardy count" do
        get admin_attendance_reports_path, params: { sort: 'tardy', dir: 'asc' }
        expect(response).to be_successful
      end

      it "sorts by excused count" do
        get admin_attendance_reports_path, params: { sort: 'excused', dir: 'desc' }
        expect(response).to be_successful
      end

      it "sorts by total" do
        get admin_attendance_reports_path, params: { sort: 'total', dir: 'asc' }
        expect(response).to be_successful
      end

      it "defaults to desc when invalid direction" do
        get admin_attendance_reports_path, params: { sort: 'total', dir: 'invalid' }
        expect(response).to be_successful
      end

      it "defaults to weighed_total when invalid sort column" do
        get admin_attendance_reports_path, params: { sort: 'invalid_column', dir: 'asc' }
        expect(response).to be_successful
      end
    end

    context "as member" do
      before do
        sign_in member
      end

      it "redirects to root path" do
        get admin_attendance_reports_path
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
