require 'rails_helper'

RSpec.describe "DisciplineRecords", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/discipline_records/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /new" do
    it "returns http success" do
      get "/discipline_records/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /create" do
    it "returns http success" do
      get "/discipline_records/create"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/discipline_records/show"
      expect(response).to have_http_status(:success)
    end
  end

end
