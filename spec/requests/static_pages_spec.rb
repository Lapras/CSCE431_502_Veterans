# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'StaticPages', type: :request do
  # Use Devise integration helpers for request specs
  include Devise::Test::IntegrationHelpers

  let(:admin) { create(:user, :admin) } # Using FactoryBot trait :admin
  let(:member) { create(:user, :member) }      # FactoryBot trait :member
  let(:norole_user) { create(:user) }          # No roles
  let(:not_member_user) { create(:user, :not_a_member) } # Trait for :not_a_member

  describe 'GET /not_a_member' do
    context 'when user is not signed in' do
      it 'redirects to the sign in page' do
        get not_a_member_path
        expect(response).to redirect_to(new_user_session_path)
        expect(response).to have_http_status(:found)
      end
    end

    context 'when user is signed in' do
      before { sign_in admin }

      it 'returns http success' do
        get not_a_member_path
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe 'GET /documentation_and_support' do
    context 'when user is allowed (has roles other than :not_a_member)' do
      before { sign_in member }

      it 'renders the page successfully' do
        get documentation_and_support_path
        expect(response).to have_http_status(:success)
        expect(response.body).to include('Documentation')
      end
    end

    context 'when user has no roles' do
      before { sign_in norole_user }

      it 'redirects to /not_a_member with alert' do
        get documentation_and_support_path
        expect(response).to redirect_to(not_a_member_path)
        expect(flash[:alert]).to eq(I18n.t('alerts.not_a_member'))
      end
    end

    context 'when user has :not_a_member role' do
      before { sign_in not_member_user }

      it 'redirects to root_path with alert' do
        get documentation_and_support_path
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq(I18n.t('alerts.not_auth_page'))
      end
    end
  end
end
