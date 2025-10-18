require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  before { @request.env['devise.mapping'] = Devise.mappings[:user] }
  controller(ApplicationController) do
    def index
      render plain: 'ok'
    end
  end

  before do
    @request.env['devise.mapping'] = Devise.mappings[:user]
    routes.draw { get 'anonymous/index' => 'anonymous#index' }
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