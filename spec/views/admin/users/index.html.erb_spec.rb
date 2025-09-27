require 'rails_helper'

RSpec.describe "admin/users/index", type: :view do
  before(:each) do
    assign(:admin_users, [
      Admin::User.create!(
        email: "Email",
        full_name: "Full Name",
        uid: "Uid",
        avatar_url: "Avatar Url"
      ),
      Admin::User.create!(
        email: "Email",
        full_name: "Full Name",
        uid: "Uid",
        avatar_url: "Avatar Url"
      )
    ])
  end

  it "renders a list of admin/users" do
    render
    cell_selector = 'div>p'
    assert_select cell_selector, text: Regexp.new("Email".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Full Name".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Uid".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Avatar Url".to_s), count: 2
  end
end
