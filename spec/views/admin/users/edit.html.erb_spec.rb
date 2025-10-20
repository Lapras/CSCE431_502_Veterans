# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'admin/users/edit', type: :view do
  it 'renders the edit user form' do
    user = User.create!(email: 'e@example.com', full_name: 'Full Name', uid: 'u1', avatar_url: '')
    assign(:user, user)

    render

    assert_select 'form[action=?][method=?]', admin_user_path(user), 'post' do
      assert_select 'input[name=?]', 'user[email]'
      assert_select 'div.field', text: /Full name:/i
      assert_select 'div.field', text: /UID:/i
      assert_select 'div.field', text: /Avatar:/i
      assert_select 'select[name=?]', 'user[role_names][]'
    end
  end
end
