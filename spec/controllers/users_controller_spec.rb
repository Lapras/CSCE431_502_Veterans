# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  render_views

  describe 'GET #profile' do
    context 'when not signed in' do
      it 'redirects to sign in' do
        get :profile
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'when signed in as a regular member' do
      let(:user) { create(:user) }

      before do
        user.add_role(:member)
        sign_in user
        get :profile
      end

      it 'assigns @user to the current_user' do
        expect(assigns(:user)).to eq(user)
      end

      it 'renders the profile template' do
        expect(response).to render_template(:profile)
      end

      it "uses the 'user' layout (not the admin layout)" do
        expect(response).to render_template(layout: 'user')
      end
    end

    context 'when signed in as an admin' do
      let(:admin) { create(:user) }

      before do
        admin.add_role(:admin)
        sign_in admin
        get :profile
      end

      it 'assigns @user to the current_user' do
        expect(assigns(:user)).to eq(admin)
      end

      it 'renders the profile template' do
        expect(response).to render_template(:profile)
      end

      it "uses the 'admin' layout" do
        expect(response).to render_template(layout: 'admin')
      end
    end
  end
end
