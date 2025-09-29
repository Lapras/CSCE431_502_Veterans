# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'admin/users/index', type: :view do
  it 'renders a list of users' do
    users = [
      User.create!(email: 'a@example.com', full_name: 'A', uid: 'u1', avatar_url: ''),
      User.create!(email: 'b@example.com', full_name: 'B', uid: 'u2', avatar_url: '')
    ]
    assign(:users, users)

    render

    expect(rendered).to include('a@example.com')
    expect(rendered).to include('b@example.com')
  end
end
