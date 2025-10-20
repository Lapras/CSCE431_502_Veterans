require 'rails_helper'

RSpec.describe "/events", type: :request do
  let(:valid_attributes)   { { title: "Concert", starts_at: 1.hour.from_now, location: "Hall" } }
  let(:invalid_attributes) { { title: "",       starts_at: nil,             location: ""    } }

  context "as a signed-in MEMBER" do
    before do
      @member = User.create!(email: "member+#{SecureRandom.hex(6)}@ex.com")
      @member.add_role(:member)
      sign_in @member
    end

    it "GET /index renders a successful response" do
      Event.create!(valid_attributes)
      get events_path
      expect(response).to have_http_status(:success)
    end

    it "GET /show renders a successful response" do
      event = Event.create!(valid_attributes)
      get event_path(event)
      expect(response).to have_http_status(:success)
    end

    it "GET /new redirects (admin only)" do
      get new_event_path
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(events_path)
    end
  end

  context "as an ADMIN" do
    before do
      @admin = User.create!(email: "admin+#{SecureRandom.hex(6)}@ex.com")
      @admin.add_role(:admin)
      sign_in @admin
    end

    it "GET /new renders a successful response" do
      get new_event_path
      expect(response).to have_http_status(:success)
    end

    it "GET /edit renders a successful response" do
      e = Event.create!(valid_attributes)
      get edit_event_path(e)
      expect(response).to have_http_status(:success)
    end

    it "POST /create with valid parameters creates a new Event and redirects" do
      expect {
        post events_path, params: { event: valid_attributes }
      }.to change(Event, :count).by(1)
      expect(response).to redirect_to(event_url(Event.last))
    end

    it "POST /create with invalid parameters returns 422" do
      post events_path, params: { event: invalid_attributes }
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "PATCH /update with valid parameters updates and redirects" do
      e = Event.create!(valid_attributes)
      patch event_path(e), params: { event: { title: "Updated Concert" } }
      expect(e.reload.title).to eq("Updated Concert")
      expect(response).to redirect_to(event_url(e))
    end

    it "PATCH /update with invalid parameters returns 422" do
      e = Event.create!(valid_attributes)
      patch event_path(e), params: { event: invalid_attributes }
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "GET /event_confirm_delete renders the confirmation page" do
      e = Event.create!(valid_attributes)
      get event_confirm_delete_event_path(e)
      expect(response).to have_http_status(:success)
    end

    it "DELETE /destroy removes the event and redirects to index" do
      e = Event.create!(valid_attributes)
      expect {
        delete event_path(e)
      }.to change(Event, :count).by(-1)
      expect(response).to redirect_to(events_url)
    end
  end
end
