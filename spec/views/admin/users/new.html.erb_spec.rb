require 'rails_helper'

RSpec.describe "admin/users/new", type: :view do
  before(:each) do
    assign(:admin_user, Admin::User.new(
      email: "MyString",
      full_name: "MyString",
      uid: "MyString",
      avatar_url: "MyString"
    ))
  end

  it "renders new admin_user form" do
    render

    assert_select "form[action=?][method=?]", admin_users_path, "post" do

      assert_select "input[name=?]", "admin_user[email]"

      assert_select "input[name=?]", "admin_user[full_name]"

      assert_select "input[name=?]", "admin_user[uid]"

      assert_select "input[name=?]", "admin_user[avatar_url]"
    end
  end
end
