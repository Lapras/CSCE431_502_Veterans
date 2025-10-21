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

  it "GET /new returns http success" do
    get new_recurring_excusal_path
    expect(response).to have_http_status(:success)
  end

  it "POST /create with valid params creates recurring excusal and redirects" do
    expect {
      post recurring_excusals_path, params: {
        recurring_excusal: {
          reason: 'Valid reason',
          recurring_start_time: '09:00',
          recurring_end_time: '10:00',
          recurring_days: ['Monday', 'Wednesday']
        }
      }
    }.to change(RecurringExcusal, :count).by(1)
    expect(response).to redirect_to(recurring_excusals_path)
  end

  it "POST /create with invalid params renders new" do
    post recurring_excusals_path, params: { recurring_excusal: { reason: '' } }
    expect(response).to have_http_status(:success)
    expect(response.body).to include('Request Recurring Excusal')
  end
end
