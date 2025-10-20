# spec/requests/admin/membership_requests_spec.rb
require 'rails_helper'

RSpec.describe "Admin::MembershipRequests", type: :request do
  before do
    # Admin user
    @admin = User.create!(email: "admin+#{SecureRandom.hex(6)}@ex.com")
    @admin.add_role(:admin)

    # Regular user requesting membership
    @requesting_user = User.create!(email: "request+#{SecureRandom.hex(6)}@ex.com")
    @requesting_user.add_role(:requesting)
  end

  context "as an admin" do
    before { sign_in @admin }

    describe "GET /index" do
      it "lists users with requesting role" do
        get admin_membership_requests_path
        expect(response).to have_http_status(:success)
        expect(response.body).to include(@requesting_user.email)
      end
    end

    describe "POST /approve" do
      it "approves a requesting user" do
        patch approve_admin_membership_request_path(@requesting_user.id)
        expect(response).to redirect_to(admin_membership_requests_path)
        follow_redirect!
        expect(response.body).to include("#{@requesting_user.email} has been approved.")
        expect(@requesting_user.reload.has_role?(:member)).to be true
        expect(@requesting_user.has_role?(:requesting)).to be false
      end
    end

    describe "POST /deny" do
      it "denies a requesting user" do
        patch deny_admin_membership_request_path(@requesting_user.id)
        expect(response).to redirect_to(admin_membership_requests_path)
        follow_redirect!
        expect(response.body).to include("#{@requesting_user.email} has been denied.")
        expect(@requesting_user.reload.has_role?(:requesting)).to be false
      end
    end
  end

  context "as a non-admin user" do
    before do
      @member = User.create!(email: "member+#{SecureRandom.hex(6)}@ex.com")
      @member.add_role(:member)
      sign_in @member
    end

    it "cannot access index" do
      get admin_membership_requests_path
      expect(response).to redirect_to(root_path)
    end

    it "cannot approve a user" do
      patch approve_admin_membership_request_path(@requesting_user.id)
      expect(response).to redirect_to(root_path)
    end

    it "cannot deny a user" do
      patch deny_admin_membership_request_path(@requesting_user.id)
      expect(response).to redirect_to(root_path)
    end
  end
end
