# frozen_string_literal: true
require "rails_helper"

RSpec.describe ApplicationController, type: :controller do
  include Devise::Test::ControllerHelpers

  # Anonymous controller so ApplicationController callbacks run
  controller do
    def index
      render plain: "ok"
    end
  end

  before do
    routes.draw { get "anon_index" => "anonymous#index" }
    # Avoid actual Devise auth work
    allow(controller).to receive(:authenticate_user!).and_return(true)
    # Stub current_user to nil so check_user_roles hits its early return
    allow(controller).to receive(:current_user).and_return(nil)
  end

  it "returns early on auth pages (devise_controller? == true), covering on_auth_pages? branch" do
    allow(controller).to receive(:devise_controller?).and_return(true)
    get :index
    expect(response).to have_http_status(:ok)
    expect(response.body).to eq("ok")
  end
end