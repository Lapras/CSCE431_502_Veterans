require 'rails_helper'

RSpec.describe "RecurringExcusals", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/recurring_excusals/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /new" do
    it "returns http success" do
      get "/recurring_excusals/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /create" do
    it "returns http success" do
      get "/recurring_excusals/create"
      expect(response).to have_http_status(:success)
    end
  end

end
