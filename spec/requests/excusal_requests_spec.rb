# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'ExcusalRequests', type: :request do
  let(:event) { Event.create!(title: 'Test Event', starts_at: 1.day.from_now, location: 'Test Location') }

  before do
    @user = User.create!(email: "ex+#{SecureRandom.hex(6)}@ex.com")
    @user.add_role(:member)
    sign_in @user
  end

  it 'GET /new returns http success' do
    get new_excusal_request_path
    expect(response).to have_http_status(:success)
  end

  it 'POST /create with valid params creates excusal request and redirects' do
    expect do
      post excusal_requests_path, params: { excusal_request: { event_id: event.id, reason: 'Valid reason' } }
    end.to change(ExcusalRequest, :count).by(1)
    expect(response).to redirect_to(events_path)
  end

  it 'POST /create with invalid params renders new with unprocessable entity' do
    post excusal_requests_path, params: { excusal_request: { event_id: nil, reason: '' } }
    expect(response).to have_http_status(:unprocessable_entity)
  end
end
