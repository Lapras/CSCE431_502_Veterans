require "rails_helper"

RSpec.describe Users::SessionsController, type: :controller do
  # Devise mapping so controller helpers work
  before { @request.env["devise.mapping"] = Devise.mappings[:user] }

  describe "#after_sign_out_path_for" do
    it "returns new_user_session_path" do
      path = controller.after_sign_out_path_for(:user)
      expect(path).to eq(new_user_session_path)
    end
  end

  describe "#after_sign_in_path_for" do
    it "returns stored location when present" do
      allow(controller).to receive(:stored_location_for).with(:user).and_return("/dashboard")
      expect(controller.after_sign_in_path_for(:user)).to eq("/dashboard")
    end

    it "falls back to root_path when stored location is nil" do
      allow(controller).to receive(:stored_location_for).with(:user).and_return(nil)
      expect(controller.after_sign_in_path_for(:user)).to eq(root_path)
    end
  end
end
