require "rails_helper"

RSpec.describe DashboardsController, type: :controller do
  before { @request.env["devise.mapping"] = Devise.mappings[:user] }

  describe "GET #show" do
    it "redirects admins to the admin dashboard" do
      admin = User.create!(email: "admin@example.com")
      admin.add_role(:admin)
      sign_in admin

      # Avoid route coupling: stub the path helper
      allow(controller).to receive(:admin_dashboard_path).and_return("/admin/dashboard")

      get :show
      expect(response).to redirect_to("/admin/dashboard")
    end

    it "assigns @user for non-admins and renders successfully" do
      user = User.create!(email: "member@example.com")
      user.add_role(:member) # prevents ApplicationController#check_user_roles redirect
      sign_in user

      get :show

      expect(response).to be_successful
      expect(controller.instance_variable_get(:@user)).to eq(user)
    end
  end
end