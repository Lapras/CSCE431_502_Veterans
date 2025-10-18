# frozen_string_literal: true
require "rails_helper"

RSpec.describe "/admin/users update roles blank array branch", type: :request do
  let(:admin)  { User.create!(full_name: "Admin",  email: "admin@example.com",  uid: "a1") }
  let(:target) { User.create!(full_name: "Target", email: "t@example.com",      uid: "t1") }

  before do
    admin.add_role(:admin)
    target.add_role(:member) # start with a role so we can prove it stays unchanged
    sign_in admin
  end

  it "early-returns when role_names is present but only blank values (keeps existing roles)" do
    patch admin_user_path(target), params: {
      user: {
        email: "t2@example.com",
        role_names: ["", " ", nil]  # present key, but all blanks
      }
    }

    expect(response).to redirect_to([:admin, target])
    target.reload
    # email still updated (normal update path ran)…
    expect(target.email).to eq("t2@example.com")
    # …but roles are unchanged because update_roles returned early.
    expect(target.roles.map(&:name)).to eq(["member"])
  end
end
