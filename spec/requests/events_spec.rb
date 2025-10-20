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
<<<<<<< HEAD

  describe "DELETE /destroy (JSON)" do
    it "deletes the event (json)" do
      event = Event.create!(valid_attributes)
      delete event_url(event),
            as: :json,
            headers: { "ACCEPT" => "application/json" }

      expect(response).to have_http_status(:no_content)
    end
  end

  describe "Admin access" do
    it "redirects non-admin users from /events/new" do
      # enable real require_admin!
      allow_any_instance_of(EventsController).to receive(:require_admin!).and_call_original

      non_admin = double("User", has_role?: false, roles: [double("Role")])
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(non_admin)

      get new_event_url
      expect(response).to redirect_to(events_path)
      follow_redirect!
      expect(response.body).to include("You must be an administrator")
    end
  end

  describe "#select_layout" do
    it "returns 'admin' when user has admin role" do
      controller = EventsController.new
      allow(controller).to receive(:current_user).and_return(double(has_role?: true, roles: [double("Role")]))
      expect(controller.send(:select_layout)).to eq("admin")
    end

    it "returns 'user' otherwise" do
      controller = EventsController.new
      allow(controller).to receive(:current_user).and_return(double(has_role?: false, roles: [double("Role")]))
      expect(controller.send(:select_layout)).to eq("user")
    end
  end

  describe "private methods" do
    it "permits correct parameters" do
      controller = EventsController.new
      params = ActionController::Parameters.new(event: valid_attributes)
      allow(controller).to receive(:params).and_return(params)

      permitted = controller.send(:event_params)
      expect(permitted.keys).to include("title", "starts_at", "location")
    end
  end
end
=======
end
>>>>>>> origin/sprint1-test-coverage
