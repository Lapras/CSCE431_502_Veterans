require 'rails_helper'

RSpec.describe "RecurringExcusals", type: :request do
  before do
    @user = User.create!(email: "rec+#{SecureRandom.hex(6)}@ex.com")
    @user.add_role(:member)
    sign_in @user
  end

  it "GET /index returns http success" do
    get recurring_excusals_path
    expect(response).to have_http_status(:success)
  end

<<<<<<< HEAD
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
=======
  it "GET /new returns http success" do
    get new_recurring_excusal_path
    expect(response).to have_http_status(:success)
>>>>>>> origin/sprint1-test-coverage
  end

  it "POST /create redirects (until we supply full valid params)" do
    post recurring_excusals_path, params: { recurring_excusal: {} }
    post recurring_excusals_path, params: { recurring_excusal: {} }
    expect(response).to have_http_status(:redirect)
      .or have_http_status(:unprocessable_entity)
      .or have_http_status(:bad_request)
  end
end