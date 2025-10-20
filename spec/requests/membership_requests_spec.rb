require 'rails_helper'

RSpec.describe "MembershipRequests", type: :request do
  let(:user) { User.create!(email: 'user@example.com', full_name: 'User') }
  let(:member) { User.create!(email: 'member@example.com', full_name: 'Member') }
  let(:requesting_user) { User.create!(email: 'requesting@example.com', full_name: 'Requesting') }

  before do
    member.add_role(:member)
    requesting_user.add_role(:requesting)
  end

  describe "POST /request_membership" do
    context "as a user with no roles" do
      before do
        sign_in user
      end

      it "creates a membership request" do
        post '/request_membership'
        user.reload
        expect(user.has_role?(:requesting)).to be true
        expect(response).to redirect_to(root_path)
      end
    end

    context "as a member" do
      before do
        sign_in member
      end

      it "redirects with alert" do
        post '/request_membership'
        expect(response).to redirect_to(root_path)
      end
    end

    context "as a requesting user" do
      before do
        sign_in requesting_user
      end

      it "redirects with alert" do
        post '/request_membership'
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
