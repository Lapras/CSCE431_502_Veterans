# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::UsersController, type: :controller do
  # Include Devise test helpers
  before { @request.env['devise.mapping'] = Devise.mappings[:user] }

  let(:admin) { create(:user, :admin) }
  let(:member) { create(:user, :member) }

  before { sign_in admin }

  describe 'PATCH #update (roles handling branches)' do
    it "clears roles when params include 'none'" do
      target = create(:user, :member)

      patch :update, params: { id: target.id, user: { email: target.email, role_names: ['none'] } }

      expect(response).to redirect_to([:admin, target])
      expect(target.reload.roles).to be_empty
    end

    it 'assigns provided roles' do
      target = create(:user)

      patch :update, params: { id: target.id, user: { email: target.email, role_names: %w[admin officer] } }

      target.reload
      expect(target.has_role?(:admin)).to be(true)
      expect(target.has_role?(:officer)).to be(true)
      expect(response).to redirect_to([:admin, target])
    end

    it 'renders 422 when invalid' do
      target = create(:user)

      patch :update, params: { id: target.id, user: { email: '' } }

      expect(response.status).to eq(422)
    end
  end

  describe 'private #update_roles' do
    it 'returns early when params[:user][:role_names] is blank' do
      allow(controller).to receive(:params)
        .and_return(ActionController::Parameters.new(user: { email: member.email }))

      member.add_role(:member)
      before_roles = member.roles.pluck(:name)

      controller.send(:update_roles, member)

      expect(member.roles.pluck(:name)).to eq(before_roles)
    end

    it 'clears roles then adds compacted role_names' do
      member.add_role(:admin)
      member.add_role(:officer)

      allow(controller).to receive(:params)
        .and_return(
          ActionController::Parameters.new(
            user: { role_names: ['member', '', 'member', nil, 'officer'] }
          )
        )

      controller.send(:update_roles, member)

      expect(member.roles.pluck(:name).sort).to eq(%w[member officer].sort)
    end
  end

  describe "PATCH #update – clears roles when 'none' provided" do
    it 'executes @user.roles = []' do
      target = create(:user, :member)

      patch :update, params: { id: target.id, user: { email: target.email, role_names: ['none'] } }

      expect(response).to redirect_to([:admin, target])
      expect(target.reload.roles).to be_empty
    end
  end
end
