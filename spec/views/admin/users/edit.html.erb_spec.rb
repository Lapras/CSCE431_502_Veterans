# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'admin/users/edit', type: :view do
  it 'renders the edit user form' do
    user = User.create!(email: 'e@example.com', full_name: 'Full Name', uid: 'u1', avatar_url: '')
    assign(:user, user)

    render

    # form_with uses POST + hidden _method=patch
    assert_select 'form[action=?][method=?]', admin_user_path(user), 'post' do
      assert_select 'input[name=?]', 'user[email]'
      assert_select 'input[name=?]', 'user[full_name]', count: 0
      assert_select 'input[name=?]', 'user[uid]', count: 0
      assert_select 'input[name=?]', 'user[avatar_url]', count: 0
    end
  end
end
