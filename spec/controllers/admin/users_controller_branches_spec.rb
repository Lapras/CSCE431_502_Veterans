# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::UsersController, type: :controller do
  render_views

  let(:admin) { User.create!(email: 'admin@example.com', full_name: 'Admin', uid: 'a1') }

  before do
    admin.add_role(:admin)
    # Pretend we’re already logged in
    allow(controller).to receive(:current_user).and_return(admin)
    # <-- Add this to bypass Devise/Warden in controller specs
    allow(controller).to receive(:authenticate_user!).and_return(true)
  end

  describe '#update (names&.any? branch)' do
    it "takes the 'then' path when role_names are present (creates roles & sets them)" do
      u = User.create!(email: 't@example.com', full_name: 'Target', uid: 't1')

      patch :update, params: { id: u.id, user: { role_names: %w[member] } }

      expect(response).to redirect_to([:admin, u])
      expect(u.reload.has_role?(:member)).to be(true)
    end
  end

  describe 'private #update_roles' do
    it 'early-returns when role_names is missing (nil)' do
      u = User.create!(email: 'n@example.com', full_name: 'Nil', uid: 'n1')

      # simulate params without :role_names
      controller.params = ActionController::Parameters.new(user: {})
      controller.send(:update_roles, u)

      expect(u.roles).to be_empty
    end

    it 'early-returns when role_names is present but only blank values' do
      u = User.create!(email: 'b@example.com', full_name: 'Blank', uid: 'b1')

      controller.params = ActionController::Parameters.new(user: { role_names: ['', ' '] })
      controller.send(:update_roles, u)

      expect(u.roles).to be_empty
    end

    it 'sets roles when role_names includes non-blank values' do
      u = User.create!(email: 's@example.com', full_name: 'Some', uid: 's1')

      controller.params = ActionController::Parameters.new(user: { role_names: ['member', ''] })
      controller.send(:update_roles, u)

      expect(u.reload.has_role?(:member)).to be(true)
    end
  end
end
