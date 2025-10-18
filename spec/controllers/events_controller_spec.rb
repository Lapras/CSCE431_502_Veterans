require "rails_helper"

RSpec.describe EventsController, type: :controller do
  before { @request.env["devise.mapping"] = Devise.mappings[:user] }

  describe "#require_admin!" do
    controller(EventsController) do
      def index
        render plain: "OK"
      end
    end

    it "redirects non-admin users to events_path with alert" do
      user = User.create!(email: "user@example.com")
      user.add_role(:member)
      sign_in user

      # Stub translation + path so no dependency on I18n or routing
      allow(controller).to receive(:events_path).and_return("/events")
      allow(I18n).to receive(:t).with("alerts.not_admin").and_return("Not admin")

      controller.send(:require_admin!)

      expect(response).to redirect_to("/events")
      expect(flash[:alert]).to eq("Not admin")
    end

    it "returns early (no redirect) for admin" do
      admin = User.create!(email: "admin@example.com")
      admin.add_role(:admin)
      sign_in admin

      expect(controller).not_to receive(:redirect_to)
      controller.send(:require_admin!)
    end
  end

  describe "#select_layout" do
    it "returns 'admin' layout for admins" do
      admin = User.create!(email: "admin@example.com")
      admin.add_role(:admin)
      sign_in admin
      expect(controller.send(:select_layout)).to eq("admin")
    end

    it "returns 'user' layout for non-admins" do
      user = User.create!(email: "user@example.com")
      user.add_role(:member)
      sign_in user
      expect(controller.send(:select_layout)).to eq("user")
    end
  end
end