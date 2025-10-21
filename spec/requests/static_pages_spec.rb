# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'StaticPages', type: :request do
  let(:admin) { User.create!(full_name: 'Admin', email: 'admin@example.com', uid: 'a1') }

  describe 'GET /not_a_member' do
    context 'when user is not signed in' do
      it 'redirects to the sign in page' do
        get not_a_member_path
        expect(response).to have_http_status(:found) # 302
        expect(response).to redirect_to(new_user_session_path) # /users/sign_in
      end
    end

    context 'when user is signed in' do
      before do
        sign_in admin
      end
      it 'returns http success' do
        get not_a_member_path
        expect(response).to have_http_status(:success) # 200
      end
    end
  end

   describe 'GET /documentation_and_support' do
    context 'when user is allowed (has roles other than :not_a_member)' do
      let(:user) { User.create!(full_name: 'Member', email: 'member@example.com', uid: 'u1') }

      before do
        sign_in user
        # Stub roles
        allow(user).to receive(:roles).and_return([double(name: 'member')])
        allow(user).to receive(:has_role?).with(:not_a_member).and_return(false)
        get documentation_and_support_path
      end

      it 'renders the page successfully' do
        expect(response).to have_http_status(:success)
        expect(response.body).to include('Documentation') # optional content check
      end
    end

    context 'when user has no roles' do
      let(:user) { User.create!(full_name: 'NoRole', email: 'norole@example.com', uid: 'u2') }

      before do
        sign_in user
        allow(user).to receive(:roles).and_return([])
        get documentation_and_support_path
      end

     it 'redirects to /not_a_member with alert' do
      expect(response).to redirect_to(not_a_member_path)
      expect(flash[:alert]).to eq(I18n.t('alerts.not_a_member'))
      end
    end

    context 'when user has :not_a_member role' do
      let(:user) { User.create!(full_name: 'NotMember', email: 'notmember@example.com', uid: 'u3') }

      before do
        sign_in user
        allow(user).to receive(:roles).and_return([double(name: 'not_a_member')])
        allow(user).to receive(:has_role?).with(:not_a_member).and_return(true)
        get documentation_and_support_path
      end

      it 'redirects to root_path with alert' do
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq(I18n.t('alerts.not_auth_page'))
      end
    end
  end
end
