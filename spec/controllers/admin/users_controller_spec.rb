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
      # give the user some roles first so clear branch is visible
      user.add_role(:member) if user.respond_to?(:add_role)

      patch :update, params: {
        id: user.id,
        user: { email: 'new_email@example.com' },
        role_names: ['none'] # <- hits @user.roles = []
      }

      expect(response).to redirect_to([:admin, assigns(:user)])
      expect(flash[:notice]).to be_present

      # Ensure roles are cleared
      if user.respond_to?(:roles)
        expect(assigns(:user).roles).to be_empty
      end
    end

    it 'ensures roles exist and calls set_roles! when concrete roles provided' do
      expect(Role).to receive(:find_or_create_by!).with(name: 'admin').and_call_original
      expect(Role).to receive(:find_or_create_by!).with(name: 'officer').and_call_original
      expect_any_instance_of(User).to receive(:set_roles!).with(array_including('admin', 'officer'))

      patch :update, params: {
        id: user.id,
        user: { email: 'another@example.com' },
        role_names: %w[admin officer] # <- hits Role.find_or_create_by! + set_roles!
      }

      expect(response).to redirect_to([:admin, assigns(:user)])
      expect(flash[:notice]).to be_present
    end

    it 'renders :edit with 422 when update fails' do
      # Email presence validation should fail
      patch :update, params: {
        id: user.id,
        user: { email: '' }, # invalid
        role_names: ['none']
      }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response).to render_template(:edit)
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

      if user.respond_to?(:roles)
        expect(user.roles.pluck(:name)).to eq(before_roles)
      end
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

      if user.respond_to?(:roles)
        expect(user.roles.pluck(:name).sort).to eq(%w[member officer].sort)
      end
    end
  end
  describe "PATCH #update – clears roles when 'none' provided" do
    it "executes @user.roles = []" do
      # authorize as admin
      admin = User.create!(email: "admin@example.com")
      admin.add_role(:admin)
      sign_in admin

      # use a real user to avoid Rolify surprises, but stub the bits we need
      target = User.create!(email: "target@example.com")
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
          role_names: ["none"]     # -> triggers the branch
        }
      }

      expect(response).to redirect_to([:admin, target])
      expect(target.reload.roles).to be_empty
    end
  end
end