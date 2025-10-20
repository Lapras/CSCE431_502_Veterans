# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "ExcusalRequests", type: :request do
  before do
    @user = User.create!(email: "ex+#{SecureRandom.hex(6)}@ex.com")
    @user.add_role(:member)
    sign_in @user

  end

  let(:event) { Event.create!(title: "Concert", starts_at: 1.hour.from_now, location: "Hall") }
  let(:valid_params) { { excusal_request: { event_id: event.id, reason: "I have a conflict" } } }
  let(:invalid_params) { { excusal_request: { event_id: nil, reason: "" } } }

  it "GET /new returns http success" do
    get new_excusal_request_path
    expect(response).to have_http_status(:success)
  end

  describe "POST #create" do
    context "as a signed-in user" do

      it "creates a new excusal request with valid parameters" do
        expect {
          post excusal_requests_path, params: valid_params
        }.to change(@user.excusal_requests, :count).by(1)
        expect(response).to redirect_to(events_path)
        expect(flash[:notice]).to eq(I18n.t('excusal.submit'))
      end

      it "renders :new with invalid parameters" do
        post excusal_requests_path, params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("Reason")  # or some text in your form
      end
    end
  end
end
