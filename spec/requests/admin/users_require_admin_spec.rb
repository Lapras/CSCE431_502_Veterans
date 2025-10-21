# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin::UsersController require_admin', type: :request do
  let(:admin) { User.create!(email: 'admin@example.com', full_name: 'Admin', uid: 'a1') }

  before { admin.add_role(:admin) }

  it 'allows an admin user through (covers require_admin else branch)' do
    sign_in admin
    get admin_users_path
    expect(response).to be_successful
    expect(response.body).to include('Users') # text from the index view
  end
end
