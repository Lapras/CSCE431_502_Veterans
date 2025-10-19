require 'rails_helper'

RSpec.describe "ExcusalRequests", type: :request do
  let(:user) { User.create!(email: 'test@example.com', full_name: 'Test User') }
  let(:event) { Event.create!(title: 'Test Event', starts_at: 1.day.from_now, location: 'Test Location') }

  before do
    # Add member role to user
    user.add_role(:member)

    # Mock authentication
    allow_any_instance_of(ApplicationController)
      .to receive(:authenticate_user!).and_return(true)
    allow_any_instance_of(ApplicationController)
      .to receive(:current_user).and_return(user)
    # Bypass the check_user_roles redirect
    allow_any_instance_of(ApplicationController)
      .to receive(:check_user_roles).and_return(true)
  end

  describe "GET /new" do
    it "returns http success" do
      get "/excusal_requests/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /create" do
    it "creates an excusal request and redirects" do
      post "/excusal_requests", params: { excusal_request: { event_id: event.id, reason: 'Test reason' } }
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(events_path)
    end
  end

end
