require 'rails_helper'

RSpec.describe "ExcusalRequests", type: :request do
  before do
    @user = User.create!(email: "ex+#{SecureRandom.hex(6)}@ex.com")
    @user.add_role(:member)
    sign_in @user
  end

  it "GET /new returns http success" do
    get new_excusal_request_path
    expect(response).to have_http_status(:success)
  end

  it "POST /create redirects (until we supply full valid params)" do
    post excusal_requests_path, params: { excusal_request: {} }
    expect(response).to have_http_status(:redirect)
      .or have_http_status(:unprocessable_entity)
      .or have_http_status(:bad_request)
  end
end