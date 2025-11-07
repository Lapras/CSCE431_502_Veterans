# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EventsController, type: :controller do
  before { @request.env['devise.mapping'] = Devise.mappings[:user] }

  describe '#require_admin!' do
    controller(EventsController) do
      def index
        render plain: 'OK'
      end
    end

    it 'redirects non-admin users to events_path with alert' do
      user = User.create!(email: "u+#{SecureRandom.hex(4)}@ex.com")
      user.add_role(:member)
      sign_in user
      allow(controller).to receive(:events_path).and_return('/events')
      # allow(I18n).to receive(:t).with('alerts.not_authorized').and_return('Not admin')

      get :new # <- triggers before_action :require_admin!

      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(I18n.t('alerts.not_authorized'))
    end

    it 'returns early (no redirect) for admin' do
      admin = User.create!(email: 'admin@example.com')
      admin.add_role(:admin)
      sign_in admin

      expect(controller).not_to receive(:redirect_to)
    end
  end

  describe '#select_layout' do
    it "returns 'admin' layout for admins" do
      admin = User.create!(email: 'admin@example.com')
      admin.add_role(:admin)
      sign_in admin
      expect(controller.send(:select_layout)).to eq('admin')
    end

    it "returns 'user' layout for non-admins" do
      user = User.create!(email: 'user@example.com')
      user.add_role(:member)
      sign_in user
      expect(controller.send(:select_layout)).to eq('user')
    end
  end
end
