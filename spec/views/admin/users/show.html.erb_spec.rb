require 'rails_helper'

RSpec.describe "admin/users/show", type: :view do
  before(:each) do
    assign(:admin_user, Admin::User.create!(
      email: "Email",
      full_name: "Full Name",
      uid: "Uid",
      avatar_url: "Avatar Url"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Email/)
    expect(rendered).to match(/Full Name/)
    expect(rendered).to match(/Uid/)
    expect(rendered).to match(/Avatar Url/)
  end
end
