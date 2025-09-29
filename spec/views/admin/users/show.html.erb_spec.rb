# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'admin/users/show', type: :view do
  it 'renders attributes' do
    user = User.create!(email: 's@example.com', full_name: 'Shown', uid: 'u3', avatar_url: '')
    assign(:user, user)

    render

    expect(rendered).to include('s@example.com')
    expect(rendered).to include('Shown')
  end
end
