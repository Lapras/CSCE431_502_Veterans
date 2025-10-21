# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::DashboardsController, type: :controller do
  before { @request.env['devise.mapping'] = Devise.mappings[:user] }

  describe 'GET #show' do
    context 'when signed in as admin' do
      let!(:admin) { User.create!(email: 'admin@example.com').tap { |u| u.add_role(:admin) } }

      before do
        sign_in admin
        # seed some users/roles WITHOUT Faker
        3.times { |i| User.create!(email: "m#{i}@example.com").add_role(:member) }
        2.times { |i| User.create!(email: "a#{i}@example.com").add_role(:admin) }
        12.times { |i| User.create!(email: "r#{i}@example.com", created_at: i.minutes.ago) }
      end

      it 'executes the expected queries (count, with_role, order.limit(10)) and responds OK' do
        # spy on the calls to prove the lines executed
        allow(User).to receive(:count).and_call_original
        allow(User).to receive(:with_role).and_call_original

        # capture the relation from order so we can assert limit(10) was called
        relation = User.order(created_at: :desc)
        allow(User).to receive(:order).with(created_at: :desc).and_return(relation)
        allow(relation).to receive(:limit).with(10).and_call_original

        get :show

        expect(response).to be_successful
        expect(User).to have_received(:count)
        expect(User).to have_received(:with_role).with(:admin)
        expect(User).to have_received(:with_role).with(:member)
        expect(User).to have_received(:order).with(created_at: :desc)
        expect(relation).to have_received(:limit).with(10)
      end
    end

    context 'when signed in but NOT admin' do
      let!(:user) { User.create!(email: 'member@example.com') } # no roles

      before { sign_in user }

      it 'redirects non-role user to not_a_member_path (due to ApplicationController check)' do
        get :show
        expect(response).to redirect_to(not_a_member_path)
        expect(flash[:alert]).to be_present
      end
    end
  end
end
