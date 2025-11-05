# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RecurringExcusalsController, type: :controller do
  let(:member) do
    user = User.create!(email: "member#{SecureRandom.hex(4)}@example.com")
    user.add_role(:member)
    user
  end

  # Add an admin user
  let(:admin) do
    user = User.create!(email: "admin#{SecureRandom.hex(4)}@example.com")
    user.add_role(:admin)
    user
  end

  # Add a pre-existing excusal for testing approve/deny
  let!(:recurring_excusal) do
    member.recurring_excusals.create!(
      reason: 'Existing appointment',
      recurring_start_time: Time.zone.now,
      recurring_end_time: 1.hour.from_now,
      recurring_days: ['Tuesday'],
      status: 'pending' # Start as pending
    )
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
        recurring_days: %w[Monday Wednesday]
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
        expect do
          post :create, params: { recurring_excusal: valid_attributes }
        end.to change(RecurringExcusal, :count).by(1)
      end

      it 'redirects to the recurring_excusals index' do
        post :create, params: { recurring_excusal: valid_attributes }
        expect(response).to redirect_to(recurring_excusals_path)
      end
    end

    context 'with invalid params' do
      it 'does not create a new RecurringExcusal' do
        expect do
          post :create, params: { recurring_excusal: invalid_attributes }
        end.not_to change(RecurringExcusal, :count)
      end

      it 'returns 200 status when validation fails' do
        post :create, params: { recurring_excusal: invalid_attributes }
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe 'PATCH #approve' do
    context 'as a non-admin (member)' do
      it 'does not update the excusal' do
        patch :approve, params: { id: recurring_excusal.id }
        expect(recurring_excusal.reload.status).to eq('pending')
      end

      it 'redirects with an authorization error' do
        patch :approve, params: { id: recurring_excusal.id }
        expect(response).to redirect_to(recurring_excusals_path)
        expect(flash[:alert]).to eq('You are not authorized to perform this action.')
      end
    end

    context 'as an admin' do
      before { sign_in admin }

      it 'updates the excusal status to approved' do
        patch :approve, params: { id: recurring_excusal.id }
        expect(recurring_excusal.reload.status).to eq('approved')
      end

      it 'redirects to the index' do
        patch :approve, params: { id: recurring_excusal.id }
        expect(response).to redirect_to(recurring_excusals_path)
        expect(flash[:notice]).to eq('Recurring excusal approved.')
      end

      it 'raises an error for a non-existent excusal' do
        expect do
          patch :approve, params: { id: 99_999 }
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe 'PATCH #deny' do
    context 'as a non-admin (member)' do
      it 'does not update the excusal' do
        patch :deny, params: { id: recurring_excusal.id }
        expect(recurring_excusal.reload.status).to eq('pending')
      end

      it 'redirects with an authorization error' do
        patch :deny, params: { id: recurring_excusal.id }
        expect(response).to redirect_to(recurring_excusals_path)
        expect(flash[:alert]).to eq('You are not authorized to perform this action.')
      end
    end

    context 'as an admin' do
      before { sign_in admin }

      it 'updates the excusal status to denied' do
        patch :deny, params: { id: recurring_excusal.id }
        expect(recurring_excusal.reload.status).to eq('denied')
      end

      it 'redirects to the index' do
        patch :deny, params: { id: recurring_excusal.id }
        expect(response).to redirect_to(recurring_excusals_path)
        expect(flash[:notice]).to eq('Recurring excusal denied.')
      end

      it 'raises an error for a non-existent excusal' do
        expect do
          patch :deny, params: { id: 99_999 }
        end.to raise_error(ActiveRecord::RecordNotFound)
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
