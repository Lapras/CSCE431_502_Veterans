# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
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
      expect {
        User.from_google(email: email, full_name: full_name, uid: uid, avatar_url: avatar_url)
      }.to change(User, :count).by(1)

      user = User.find_by(email: email)
      expect(user.full_name).to eq(full_name)
      expect(user.uid).to eq(uid)
      expect(user.avatar_url).to eq(avatar_url)
    end

    it 'finds the existing user by email without creating new one' do
      existing_user = User.create!(email: email)
      expect {
        user = User.from_google(email: email, full_name: full_name, uid: uid, avatar_url: avatar_url)
        expect(user.id).to eq(existing_user.id)
      }.not_to change(User, :count)
    end
  end

  describe '#set_roles!' do
    let(:user) { User.create!(email: 'roleuser@example.com') }

    before do
      allow(user).to receive(:roles).and_return(double(
        pluck: [],
        each: nil,
        remove_role: nil,
        add_role: nil
      ))
    end

    it 'calls remove_role for roles that are not in new names' do
      allow(user.roles).to receive(:pluck).and_return(['admin', 'editor'])
      expect(user).to receive(:remove_role).with('admin')
      expect(user).to receive(:remove_role).with('editor')
      expect(user).to receive(:add_role).with('user')

      user.set_roles!(['user'])
    end

    it 'calls add_role for new roles not already assigned' do
      allow(user.roles).to receive(:pluck).and_return(['admin'])
      expect(user).to receive(:remove_role).with('admin')
      expect(user).to receive(:add_role).with('user')
      user.set_roles!(['user'])
    end
  end
end
