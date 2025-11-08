# frozen_string_literal: true

require 'rails_helper'
require 'cancan/matchers'

RSpec.describe Ability, type: :model do
  describe 'for an admin user' do
    let(:admin) do
      user = User.create!(email: 'admin@example.com')
      user.add_role(:admin)
      user
    end

    subject(:ability) { Ability.new(admin) }

    it 'can manage all' do
      expect(ability).to be_able_to(:manage, :all)
    end

    it 'can create events' do
      expect(ability).to be_able_to(:create, Event)
    end

    it 'can update events' do
      event = Event.new
      expect(ability).to be_able_to(:update, event)
    end

    it 'can destroy events' do
      event = Event.new
      expect(ability).to be_able_to(:destroy, event)
    end
  end

  describe 'for a non-admin user' do
    let(:member) do
      user = User.create!(email: 'member@example.com')
      user.add_role(:member)
      user
    end

    subject(:ability) { Ability.new(member) }

    it 'cannot manage all' do
      expect(ability).not_to be_able_to(:manage, :all)
    end

    it 'cannot create events' do
      expect(ability).not_to be_able_to(:create, Event)
    end

    it 'cannot destroy events' do
      event = Event.new
      expect(ability).not_to be_able_to(:destroy, event)
    end
  end
end
