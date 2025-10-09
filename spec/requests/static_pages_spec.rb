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
end