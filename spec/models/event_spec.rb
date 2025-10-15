# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Role gate', type: :request do
  before do
    allow_any_instance_of(ApplicationController).to receive(:authenticate_user!).and_return(true)
  end

  it 'redirects to /not_a_member when current_user has no roles' do
    user = double('User', roles: [], has_role?: false)
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)

    get events_url
    expect(response).to redirect_to('/not_a_member')
  end

  it 'allows through when current_user has at least one role' do
    user = double('User', roles: [double('Role')], has_role?: true)
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)

    get events_url
    expect(response).to be_successful
  end
end
