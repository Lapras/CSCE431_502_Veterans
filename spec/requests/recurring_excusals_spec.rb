require 'rails_helper'

RSpec.describe "RecurringExcusals", type: :request do
  let(:user) { User.create!(email: 'test@example.com', full_name: 'Test User') }

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

  describe "GET /index" do
    it "returns http success" do
      get "/recurring_excusals"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /new" do
    it "returns http success" do
      get "/recurring_excusals/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /create" do
    it "creates a recurring excusal and redirects" do
      post "/recurring_excusals", params: {
        recurring_excusal: {
          reason: 'Test reason',
          recurring_days: [1, 3],
          recurring_start_time: '09:00',
          recurring_end_time: '10:00'
        }
      }
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(recurring_excusals_path)
    end
  end

end
