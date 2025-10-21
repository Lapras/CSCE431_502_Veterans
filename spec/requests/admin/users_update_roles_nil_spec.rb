# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/admin/users update_roles nil branch', type: :request do
  let(:admin)  { User.create!(full_name: 'Admin',  email: 'admin@example.com',  uid: 'a1') }
  let(:target) { User.create!(full_name: 'Target', email: 't@example.com',      uid: 't1') }

  before do
    admin.add_role(:admin)
    target.add_role(:member)
    sign_in admin
  end

  it 'returns early when role_names param is completely missing (covers names.nil? path)' do
    patch admin_user_path(target), params: {
      user: { email: 't2@example.com' } # no role_names key at all
    }

    expect(response).to redirect_to([:admin, target])
    target.reload
    expect(target.email).to eq('t2@example.com')
    # Role unchanged — proves early-return hit
    expect(target.roles.map(&:name)).to eq(['member'])
  end
end
