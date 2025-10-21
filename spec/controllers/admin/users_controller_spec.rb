# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::UsersController, type: :controller do
  # Devise helpers
  before { @request.env['devise.mapping'] = Devise.mappings[:user] }

  let!(:admin) { User.create!(email: 'admin@example.com') }
  let!(:user)  { User.create!(email: 'member@example.com') }

  before do
    # Sign in an admin user; if your app gates this by role, give them one.
    sign_in admin if respond_to?(:sign_in)
    admin.add_role(:admin) if admin.respond_to?(:add_role)
  end

  describe 'PATCH #update (roles handling branches)' do
    it "clears roles when params include 'none'" do
      admin = User.create!(email: "admin+#{SecureRandom.hex(4)}@ex.com")
      admin.add_role(:admin)
      sign_in admin
      user = User.create!(email: "target+#{SecureRandom.hex(4)}@ex.com")
      user.add_role(:member)

      patch :update, params: { id: user.id, user: { email: user.email, role_names: ['none'] } }

      expect(response).to redirect_to([:admin, user])
      expect(user.reload.roles).to be_empty
    end

    it 'assigns provided roles' do
      admin = User.create!(email: "admin+#{SecureRandom.hex(4)}@ex.com")
      admin.add_role(:admin)
      sign_in admin
      user  = User.create!(email: "target+#{SecureRandom.hex(4)}@ex.com")

      patch :update, params: { id: user.id, user: { email: user.email, role_names: %w[admin officer] } }

      user.reload
      expect(user.has_role?(:admin)).to be(true)
      expect(user.has_role?(:officer)).to be(true)
      expect(response).to redirect_to([:admin, user])
    end

    it 'renders 422 when invalid' do
      admin = User.create!(email: "admin+#{SecureRandom.hex(4)}@ex.com")
      admin.add_role(:admin)
      sign_in admin
      user  = User.create!(email: "target+#{SecureRandom.hex(4)}@ex.com")

      patch :update, params: { id: user.id, user: { email: '' } }

      expect(response.status).to eq(422)
    end
  end

  describe 'private #update_roles' do
    # We call the private method directly to cover those lines
    it 'returns early when params[:user][:role_names] is blank' do
      # simulate params missing role_names
      allow(controller).to receive(:params)
        .and_return(ActionController::Parameters.new(user: { email: user.email }))

      # Give a role to observe that nothing changes
      user.add_role(:member) if user.respond_to?(:add_role)
      before_roles = user.roles.pluck(:name) if user.respond_to?(:roles)

      controller.send(:update_roles, user) # should no-op

      expect(user.roles.pluck(:name)).to eq(before_roles) if user.respond_to?(:roles)
    end

    it 'clears roles then adds compacted role_names' do
      # Start user with two roles that should be cleared
      user.add_role(:admin) if user.respond_to?(:add_role)
      user.add_role(:officer) if user.respond_to?(:add_role)

      # Prepare params with blanks to hit compact_blank
      allow(controller).to receive(:params)
        .and_return(
          ActionController::Parameters.new(
            user: { role_names: ['member', '', 'member', nil, 'officer'] }
          )
        )

      controller.send(:update_roles, user)

      expect(user.roles.pluck(:name).sort).to eq(%w[member officer].sort) if user.respond_to?(:roles)
    end
  end
  describe "PATCH #update – clears roles when 'none' provided" do
    it 'executes @user.roles = []' do
      # authorize as admin
      admin = User.create!(email: "admin+#{SecureRandom.hex(4)}@example.com")
      admin.add_role(:admin)
      sign_in admin

      # use a real user to avoid Rolify surprises, but stub the bits we need
      target = User.create!(email: "target+#{SecureRandom.hex(4)}@example.com")
      target.add_role(:member)

      # make the controller use *our* target as @user (bypasses set_user -> find)
      allow(controller).to receive(:set_user) { controller.instance_variable_set(:@user, target) }

      # force the happy path regardless of validations
      allow(target).to receive(:update).and_return(true)

      # PROVE the exact line is executed
      expect(target).to receive(:roles=).with([]).and_call_original

      patch :update, params: {
        id: target.id,
        user: {
          email: target.email,     # anything to keep update "valid"
          role_names: ['none']     # -> triggers the branch
        }
      }

      expect(response).to redirect_to([:admin, target])
      expect(target.reload.roles).to be_empty
    end
  end
end
