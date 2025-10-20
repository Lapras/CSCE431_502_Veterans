require 'rails_helper'

RSpec.describe "Admin::MembershipRequests", type: :request do
  let(:admin) { User.create!(email: 'admin@example.com', full_name: 'Admin User') }
  let(:requesting_user) { User.create!(email: 'requesting@example.com', full_name: 'Requesting User') }

  before do
    admin.add_role(:admin)
    requesting_user.add_role(:requesting)
  end

  describe "GET /admin/membership_requests" do
    context "as admin" do
      before do
        sign_in admin
      end

      it "returns success" do
        get admin_membership_requests_path
        expect(response).to be_successful
      end
    end

    context "as non-admin" do
      before do
        sign_in requesting_user
      end

      it "redirects to root path" do
        get admin_membership_requests_path
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "PATCH /admin/membership_requests/:id/approve" do
    context "as admin" do
      before do
        sign_in admin
      end

      it "approves the membership request" do
        patch approve_admin_membership_request_path(requesting_user)
        requesting_user.reload
        expect(requesting_user.has_role?(:member)).to be true
        expect(requesting_user.has_role?(:requesting)).to be false
        expect(response).to redirect_to(admin_membership_requests_path)
      end
    end
  end

  describe "PATCH /admin/membership_requests/:id/deny" do
    context "as admin" do
      before do
        sign_in admin
      end

      it "denies the membership request" do
        patch deny_admin_membership_request_path(requesting_user)
        requesting_user.reload
        expect(requesting_user.has_role?(:requesting)).to be false
        expect(response).to redirect_to(admin_membership_requests_path)
      end
    end
  end
end
