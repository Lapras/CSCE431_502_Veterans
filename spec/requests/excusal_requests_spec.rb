# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'ExcusalRequests', type: :request do
  let(:event) { Event.create!(title: 'Test Event', starts_at: 1.day.from_now, location: 'Test Location') }

  before do
    @user = User.create!(email: "ex+#{SecureRandom.hex(6)}@ex.com")
    @user.add_role(:member)
    sign_in @user
  end

  let(:event) { Event.create!(title: 'Concert', starts_at: 1.hour.from_now, location: 'Hall') }
  let(:valid_params) { { excusal_request: { event_id: event.id, reason: 'I have a conflict' } } }
  let(:invalid_params) { { excusal_request: { event_id: nil, reason: '' } } }

  it 'GET /new returns http success' do
    get new_excusal_request_path
    expect(response).to have_http_status(:success)
  end

  describe 'POST #create' do
    context 'as a signed-in user' do
      it 'creates a new excusal request with valid parameters' do
        expect do
          post excusal_requests_path, params: valid_params
        end.to change(@user.excusal_requests, :count).by(1)
        expect(response).to redirect_to(events_path)
        expect(flash[:notice]).to eq(I18n.t('excusal.submit'))
      end

      it 'renders :new with invalid parameters' do
        post excusal_requests_path, params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include('Reason') # or some text in your form
      end
    end
  end

  describe 'scopes and status helpers' do
    let!(:pending_request) do
      ExcusalRequest.create!(user: @user, event: event, status: 'pending', reason: 'Pending reason')
    end
    let!(:approved_request) do
      ExcusalRequest.create!(user: @user, event: event, status: 'approved', reason: 'Approved reason')
    end
    let!(:denied_request) do
      ExcusalRequest.create!(user: @user, event: event, status: 'denied', reason: 'Denied reason')
    end
    let!(:nil_status_request) do
      ExcusalRequest.create!(user: @user, event: event, status: nil, reason: 'Nil status reason')
    end

    it 'returns pending requests including nil status' do
      expect(ExcusalRequest.pending).to include(pending_request, nil_status_request)
      expect(ExcusalRequest.pending).not_to include(approved_request, denied_request)
    end

    it 'returns approved requests only' do
      expect(ExcusalRequest.approved).to include(approved_request)
      expect(ExcusalRequest.approved).not_to include(pending_request, denied_request, nil_status_request)
    end

    it 'returns denied requests only' do
      expect(ExcusalRequest.denied).to include(denied_request)
      expect(ExcusalRequest.denied).not_to include(pending_request, approved_request, nil_status_request)
    end

    it 'correctly reports pending?, approved?, denied? status' do
      expect(pending_request.pending?).to be true
      expect(approved_request.approved?).to be true
      expect(denied_request.denied?).to be true

      # Negative cases
      expect(pending_request.approved?).to be false
      expect(approved_request.denied?).to be false
      expect(denied_request.pending?).to be false
    end
  end
end
