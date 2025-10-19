# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  before(:all) do
    RSpec::Mocks.space.proxy_for(User).reset if RSpec::Mocks.space.registered?(User)
  end

  describe 'validations' do
    it 'validates presence of email' do
      user = User.new(email: nil)
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("can't be blank")
    end
  end

  describe '.from_google' do
    let(:email) { 'user@example.com' }
    let(:full_name) { 'Test User' }
    let(:uid) { '12345' }
    let(:avatar_url) { 'http://avatar.url/image.png' }

    it 'creates a new user with given attributes if not found' do
      expect do
        User.from_google(email: email, full_name: full_name, uid: uid, avatar_url: avatar_url)
      end.to change(User, :count).by(1)

      user = User.find_by(email: email)
      expect(user.full_name).to eq(full_name)
      expect(user.uid).to eq(uid)
      expect(user.avatar_url).to eq(avatar_url)
    end

    it 'finds the existing user by email without creating new one' do
      existing_user = User.create!(email: email)
      expect do
        user = User.from_google(email: email, full_name: full_name, uid: uid, avatar_url: avatar_url)
        expect(user.id).to eq(existing_user.id)
      end.not_to change(User, :count)
    end
  end
  describe '#set_roles!' do
    let(:user) { User.create!(email: "role+#{SecureRandom.hex(6)}@ex.com") }

    before do
      # ensure no residual stubbing or doubles affect Rolify
      allow_any_instance_of(User).to receive(:roles).and_call_original
    end

    it 'removes all roles when names is nil' do
      user.add_role(:admin)
      user.add_role(:officer)
      user.set_roles!(nil)
      expect(user.roles).to be_empty
    end

    it 'normalizes strings/symbols and drops blanks' do
      user.add_role(:admin)
      user.set_roles!([:member, '', ' ', nil, 'admin'])
      expect(user.has_role?(:admin)).to be(true)
      expect(user.has_role?(:member)).to be(true)
      expect(user.has_role?(:officer)).to be(false)
    end

    it 'no-op when incoming set equals current set' do
      user.add_role(:admin)
      user.add_role(:member)
      expect {
        user.set_roles!(['member', :admin, '', 'admin'])
      }.not_to change { user.roles.pluck(:name).sort }
    end
  end
end
