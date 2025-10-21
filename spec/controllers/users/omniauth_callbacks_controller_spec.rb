require 'rails_helper'

RSpec.describe Users::OmniauthCallbacksController, type: :controller do
  before { @request.env['devise.mapping'] = Devise.mappings[:user] }

  let(:auth_hash) do
    OmniAuth::AuthHash.new(
      provider: 'google_oauth2',
      uid: '999',
      info: { email: 'user@example.com', name: 'Test User', image: 'https://ex/a.png' }
    )
  end

  describe '#google_oauth2' do
    before { @request.env['omniauth.auth'] = auth_hash }

    it 'success: creates/finds user, signs in, flashes success, redirects' do
      # Return a real user so Devise can sign in and redirect normally
      user = User.create!(email: 'user@example.com')
      allow(User).to receive(:from_google).and_return(user)

      get :google_oauth2

      expect(User).to have_received(:from_google)
      expect(flash[:success]).to eq(I18n.t('devise.omniauth_callbacks.success', kind: 'Google'))
      expect(response).to be_redirect
    end

    it 'failure: flashes alert and redirects to new session path' do
      allow(User).to receive(:from_google).and_return(nil)

      get :google_oauth2

      expect(flash[:alert]).to include('not authorized')
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe 'path helpers' do
    it 'after_omniauth_failure_path_for returns login path' do
      expect(controller.send(:after_omniauth_failure_path_for, :user)).to eq(new_user_session_path)
    end

    it 'after_sign_in_path_for returns stored location when present else root' do
      allow(controller).to receive(:stored_location_for).and_return('/dash')
      expect(controller.send(:after_sign_in_path_for, :user)).to eq('/dash')

      allow(controller).to receive(:stored_location_for).and_return(nil)
      expect(controller.send(:after_sign_in_path_for, :user)).to eq(root_path)
    end
  end
end
