# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RecurringExcusalsController, type: :controller do
  let(:member) do
    user = User.create!(email: "member#{SecureRandom.hex(4)}@example.com")
    user.add_role(:member)
    user
  end

  before do
    sign_in member
  end

  describe 'GET #index' do
    it 'returns a success response' do
      get :index
      expect(response).to be_successful
    end
  end

  describe 'GET #new' do
    it 'returns a success response' do
      get :new
      expect(response).to be_successful
    end
  end

  describe 'POST #create' do
    let(:valid_attributes) do
      {
        reason: 'Weekly doctor appointment',
        recurring_start_time: Time.zone.now,
        recurring_end_time: 1.hour.from_now,
        recurring_days: ['Monday', 'Wednesday']
      }
    end

    let(:invalid_attributes) do
      {
        reason: '',
        recurring_days: []
      }
    end

    context 'with valid params' do
      it 'creates a new RecurringExcusal' do
        expect {
          post :create, params: { recurring_excusal: valid_attributes }
        }.to change(RecurringExcusal, :count).by(1)
      end

      it 'redirects to the recurring_excusals index' do
        post :create, params: { recurring_excusal: valid_attributes }
        expect(response).to redirect_to(recurring_excusals_path)
      end
    end

    context 'with invalid params' do
      it 'does not create a new RecurringExcusal' do
        expect {
          post :create, params: { recurring_excusal: invalid_attributes }
        }.not_to change(RecurringExcusal, :count)
      end

      it 'returns 200 status when validation fails' do
        post :create, params: { recurring_excusal: invalid_attributes }
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe 'authentication' do
    context 'when not signed in' do
      before { sign_out member }

      it 'redirects to sign in for index' do
        get :index
        expect(response).to redirect_to(new_user_session_path)
      end

      it 'redirects to sign in for new' do
        get :new
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
