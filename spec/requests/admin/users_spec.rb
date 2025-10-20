# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/admin/users', type: :request do
  let(:admin) { User.create!(full_name: 'Admin', email: 'admin@example.com', uid: 'a1') }

  let(:valid_attributes) do
    { full_name: 'New Person', email: 'new@example.com', uid: 'u1', avatar_url: '' }
  end

  let(:invalid_attributes) do
    { full_name: '', email: '', uid: '' }
  end

  before do
    admin.add_role(:admin)
    sign_in admin
  end

  describe 'GET /index' do
    context 'with_admin' do
      it 'renders a successful response' do
        User.create!(full_name: 'X', email: 'x@example.com', uid: 'x1')
        get admin_users_url
        expect(response).to be_successful
      end

      context 'without_admin' do
        before do
          admin.remove_role(:admin)
          admin.add_role(:member)
        end

        it 'redirects to not a member' do
          get admin_users_url
          expect(flash[:alert]).to eq('You must be an administrator to perform this action.')
        end
      end
    end
  end

  describe 'GET /show' do
    it 'renders a successful response' do
      user = User.create!(full_name: 'X', email: 'x@example.com', uid: 'x1')
      get admin_user_url(user)
      expect(response).to be_successful
    end
  end

  describe 'GET /new' do
    it 'renders a successful response' do
      get new_admin_user_url
      expect(response).to be_successful
    end
  end

  describe 'GET /edit' do
    it 'renders a successful response' do
      user = User.create!(full_name: 'X', email: 'x@example.com', uid: 'x1')
      get edit_admin_user_url(user)
      expect(response).to be_successful
    end
  end

  describe 'POST /create' do
    context 'with valid parameters' do
      it 'creates a new User' do
        expect do
          post admin_users_url, params: { user: valid_attributes.merge(role_names: %w[member]) }
        end.to change(User, :count).by(1)
      end

      it 'redirects to the created user' do
        post admin_users_url, params: { user: valid_attributes }
        expect(response).to redirect_to(admin_user_url(User.last))
      end
    end

    context 'none roles' do
      it 'creates a new User' do
        expect do
          post admin_users_url, params: { user: valid_attributes }
        end.to change(User, :count).by(1)
      end

      it 'creates a user with no roles' do
        post admin_users_url, params: { user: valid_attributes }

        user = User.last
        expect(user.roles).to be_empty
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new User' do
        expect do
          post admin_users_url, params: { user: invalid_attributes }
        end.not_to change(User, :count)
      end

      it 'renders 422' do
        post admin_users_url, params: { user: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'PATCH /update' do
    it 'updates and redirects' do
      sign_in admin
      user = User.create!(full_name: 'Old', email: 'old@example.com', uid: '123', avatar_url: '')
      patch admin_user_url(user), params: { user: { email: 'new@example.com' } }
      expect(response).to redirect_to([:admin, user])
      expect(user.reload.email).to eq('new@example.com')
    end
  end

  describe 'DELETE /destroy' do
    it 'destroys and redirects' do
      sign_in admin
      user = User.create!(full_name: 'X', email: 'x2@example.com', uid: 'x2')
      expect { delete admin_user_url(user) }.to change(User, :count).by(-1)
      expect(response).to redirect_to(admin_users_url)
    end
  end

  # ---------- admin gate covering require_admin! (bypass role gate) ----------
  describe 'admin gate' do
    it 'redirects non-admins to root with an alert (covers require_admin!)' do
      sign_out admin
      non_admin = User.create!(full_name: 'Basic', email: 'basic@example.com', uid: 'b1')
      non_admin.add_role(:member) # bypass check_user_roles
      sign_in non_admin

      get admin_users_path
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to be_present
    end
  end

  # ---------- roles/update edge cases ----------
  describe 'PATCH /admin/users/:id roles edge cases' do
    it 'does NOT change roles when role_names is missing (covers update_roles early return)' do
      sign_in admin
      target = User.create!(full_name: 'T', email: 't@example.com', uid: 't1')
      target.add_role(:member)

      patch admin_user_path(target), params: { user: { full_name: 'T2' } }
      expect(response).to redirect_to([:admin, target])

      target.reload
      expect(target.full_name).to eq('T2')                 # updated user attrs
      expect(target.roles.map(&:name)).to eq(['member'])   # roles unchanged
    end

    it 'renders :edit with 422 when the update fails (covers update else branch)' do
      sign_in admin
      u = User.create!(full_name: 'F', email: 'f@example.com', uid: 'ff1')

      patch admin_user_path(u), params: { user: { email: '' } }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include('<h1>Edit User</h1>') # avoid render_template matcher
    end
  end

  # ---------- additional guard/early-return coverage ----------
  describe 'edge cases for Admin::UsersController' do
    it 'redirects to root when current_user is not an admin (covers require_admin!)' do
      sign_out admin
      u = User.create!(full_name: 'N', email: 'n@example.com', uid: 'n1')
      u.add_role(:member) # bypass role gate
      sign_in u

      get new_admin_user_path
      expect(response).to redirect_to(root_path)
    end

    it 'redirects to root when a non-admin hits the admin pages' do
      sign_out admin
      u = User.create!(full_name: 'N2', email: 'n2@example.com', uid: 'n2')
      u.add_role(:member)
      sign_in u

      get admin_user_path(admin)
      expect(response).to redirect_to(root_path)
    end

    it 'returns early from update_roles when role_names is blank' do
      sign_in admin
      u = User.create!(full_name: 'Roleless', email: 'roleless@example.com', uid: 'r1')
      u.add_role(:member)

      patch admin_user_path(u), params: { user: { full_name: 'Still Roleless' } }
      expect(response).to redirect_to([:admin, u])
      expect(u.reload.full_name).to eq('Still Roleless')
      expect(u.roles.map(&:name)).to eq(['member']) # unchanged proves early return
    end
  end
end
