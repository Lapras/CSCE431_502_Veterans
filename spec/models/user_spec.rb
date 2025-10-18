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
      allow(user.roles).to receive(:pluck).and_return(%w[admin editor])
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

    describe '#set_roles!' do
    let(:user) { User.create!(email: 'roleuser@example.com') }

    before do
      # The method calls roles.pluck(:name). We stub a roles proxy that responds to pluck.
      allow(user).to receive(:roles).and_return(double(pluck: [], each: nil))
      # Also allow add/remove to be observed on the user.
      allow(user).to receive(:add_role).and_call_original
      allow(user).to receive(:remove_role).and_call_original
    end

    it 'removes all roles when names is nil (covers Array(nil) + compact_blank)' do
      allow(user.roles).to receive(:pluck).and_return(%w[admin officer])
      expect(user).to receive(:remove_role).with('admin')
      expect(user).to receive(:remove_role).with('officer')
      user.set_roles!(nil)
    end

    it 'normalizes strings/symbols and drops blanks (covers map(&:to_s) + compact_blank)' do
      allow(user.roles).to receive(:pluck).and_return(['admin'])
      expect(user).to receive(:remove_role).with('admin') # not in new set
      expect(user).to receive(:add_role).with('member')   # added
      # Includes symbol + blank entries to exercise normalization
      user.set_roles!([:member, '', ' ', nil])
    end

    it 'does nothing when incoming set equals current set (no-op branch)' do
      allow(user.roles).to receive(:pluck).and_return(%w[admin member])
      expect(user).not_to receive(:remove_role)
      expect(user).not_to receive(:add_role)
      # Same roles, reordered, with duplicates/blanks to still reduce to same set
      user.set_roles!(['member', :admin, '', 'admin'])
    end
  end
end
