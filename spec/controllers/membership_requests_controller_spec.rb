# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MembershipRequestsController, type: :controller do
  let(:user) { User.create!(email: "user#{SecureRandom.hex(4)}@example.com") }

  before do
    sign_in user
  end

  describe 'POST #create' do
    context 'when user has no roles' do
      it 'adds requesting role and redirects' do
        post :create
        expect(user.reload.has_role?(:requesting)).to be true
        expect(response).to redirect_to(root_path)
        expect(flash[:notice]).to be_present
      end
    end

    context 'when user already has member role' do
      before { user.add_role(:member) }

      it 'redirects with alert' do
        post :create
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to be_present
      end
    end

    context 'when user already has requesting role' do
      before { user.add_role(:requesting) }

      it 'redirects with alert' do
        post :create
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to be_present
      end
    end
  end

  describe 'authentication' do
    context 'when not signed in' do
      before { sign_out user }

      it 'redirects to sign in' do
        post :create
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
