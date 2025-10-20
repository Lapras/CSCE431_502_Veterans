# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  include Devise::Test::ControllerHelpers

  # Anonymous controller so ApplicationController callbacks run
  controller(ApplicationController) do
    def index
      render plain: 'ok'
    end
  end

  before do
    @request.env['devise.mapping'] = Devise.mappings[:user]
    routes.draw { get 'anonymous/index' => 'anonymous#index' }
  end

  it 'returns early on auth pages (devise_controller? == true), covering on_auth_pages? branch' do
    allow(controller).to receive(:devise_controller?).and_return(true)
    # Avoid actual Devise auth work
    allow(controller).to receive(:authenticate_user!).and_return(true)
    # Stub current_user to nil so check_user_roles hits its early return
    allow(controller).to receive(:current_user).and_return(nil)
    get :index
    expect(response).to have_http_status(:ok)
    expect(response.body).to eq('ok')
  end

  it 'redirects users with no roles to not_a_member_path' do
    user = User.create!(email: 'noroles@example.com') # no roles
    sign_in user
    allow(controller).to receive(:not_a_member_path).and_return('/not_a_member')

    get :index

    expect(response).to redirect_to('/not_a_member')
    expect(flash[:alert]).to be_present
  end
end
