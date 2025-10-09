# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'StaticPages', type: :request do
describe 'GET /not_a_member' do
    context 'when user is not signed in' do
      it 'redirects to the sign in page' do
        get not_a_member_path
        expect(response).to have_http_status(:found) # 302
        expect(response).to redirect_to(new_user_session_path) # /users/sign_in
      end
    end

    context 'when user is signed in' do
      let(:user) { create(:user) }

      before { sign_in user }

      it 'returns http success' do
        get not_a_member_path
        expect(response).to have_http_status(:success) # 200
      end
    end
  end
end