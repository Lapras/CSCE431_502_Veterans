require 'rails_helper'

RSpec.describe "admin/users/edit", type: :view do
  let(:admin_user) {
    Admin::User.create!(
      email: "MyString",
      full_name: "MyString",
      uid: "MyString",
      avatar_url: "MyString"
    )
  }

  before(:each) do
    assign(:admin_user, admin_user)
  end

  it "renders the edit admin_user form" do
    render

    assert_select "form[action=?][method=?]", admin_user_path(admin_user), "post" do

      assert_select "input[name=?]", "admin_user[email]"

      assert_select "input[name=?]", "admin_user[full_name]"

      assert_select "input[name=?]", "admin_user[uid]"

      assert_select "input[name=?]", "admin_user[avatar_url]"
    end
  end
end
