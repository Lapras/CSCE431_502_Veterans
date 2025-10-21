# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'admin/users/new', type: :view do
  it 'renders new user form' do
    assign(:user, User.new)

    render

    assert_select 'form[action=?][method=?]', admin_users_path, 'post' do
      assert_select 'input[name=?]', 'user[email]'
      assert_select 'input[name=?]', 'user[full_name]'
      assert_select 'input[name=?]', 'user[uid]', count: 0
      assert_select 'input[name=?]', 'user[avatar_url]', count: 0
      assert_select 'select[name=?]', 'user[role_names][]'
    end
  end
end
