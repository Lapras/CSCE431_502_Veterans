# frozen_string_literal: true
require "rails_helper"

RSpec.describe "Events layouts and admin gate", type: :request do
  let(:admin)  { User.create!(full_name: "Admin",  email: "admin@example.com",  uid: "a1") }
  let(:member) { User.create!(full_name: "Member", email: "member@example.com", uid: "m1") }

  before do
    admin.add_role(:admin)
    member.add_role(:member)
  end

  describe "require_admin before_action" do
    it "allows an admin through (covers require_admin else branch)" do
      sign_in admin
      get new_event_path
      expect(response).to be_successful
      # Also proves the admin layout path was taken:
      expect(response.body).to include("Admin Panel")
    end

    it "redirects a non-admin (covers require_admin then branch)" do
      sign_in member
      get new_event_path
      expect(response).to redirect_to(events_path)
      follow_redirect!
      expect(response.body).to include("Events")
    end
  end

  describe "#select_layout" do
    it "uses the 'admin' layout for admins" do
      sign_in admin
      get events_path
      expect(response).to be_successful
      expect(response.body).to include("Admin Panel") # unique to admin layout
    end

    it "uses the 'user' layout for regular users (covers else branch)" do
      sign_in member
      get events_path
      expect(response).to be_successful
      expect(response.body).not_to include("Admin Panel")
    end
  end
end