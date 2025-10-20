# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::AttendanceReportsController, type: :controller do
  let(:admin) do
    user = User.create!(email: "admin#{SecureRandom.hex(4)}@example.com")
    user.add_role(:admin)
    user
  end

  let(:member) do
    user = User.create!(email: "member#{SecureRandom.hex(4)}@example.com")
    user.add_role(:member)
    user
  end

  before do
    sign_in admin
  end

  describe 'GET #index' do
    it 'returns a success response' do
      get :index
      expect(response).to be_successful
    end

    it 'renders successfully with users' do
      member # create it
      get :index
      expect(response).to be_successful
    end

    context 'with search query' do
      it 'filters users by email successfully' do
        get :index, params: { q: member.email }
        expect(response).to be_successful
      end

      it 'filters users by full_name successfully' do
        user_with_name = User.create!(email: 'john@example.com', full_name: 'John Doe')
        user_with_name.add_role(:member)

        get :index, params: { q: 'John' }
        expect(response).to be_successful
      end
    end

    context 'with sorting' do
      it 'sorts by full_name ascending' do
        get :index, params: { sort: 'full_name', dir: 'asc' }
        expect(response).to be_successful
      end

      it 'sorts by full_name descending' do
        get :index, params: { sort: 'full_name', dir: 'desc' }
        expect(response).to be_successful
      end

      it 'sorts by email' do
        get :index, params: { sort: 'email', dir: 'asc' }
        expect(response).to be_successful
      end

      it 'sorts by demerit_points' do
        get :index, params: { sort: 'demerit_points', dir: 'desc' }
        expect(response).to be_successful
      end
    end
  end

  describe 'authentication and authorization' do
    context 'when not signed in' do
      before { sign_out admin }

      it 'redirects to sign in' do
        get :index
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'when signed in as non-admin' do
      before do
        sign_out admin
        sign_in member
      end

      it 'redirects to root path' do
        get :index
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
