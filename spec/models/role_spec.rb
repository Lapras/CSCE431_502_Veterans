# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Role, type: :model do
  describe 'creation' do
    it 'is valid with a valid name and no resource_type' do
      role = Role.new(name: 'admin', resource_type: nil)
      expect(role).to be_valid
    end

    it 'is invalid with an invalid resource_type' do
      role = Role.new(name: 'admin', resource_type: 'InvalidType')
      role.valid?  
      expect(role.errors[:resource_type]).to include('is not included in the list')
    end
  end

  describe 'associations' do
    it 'can have many users' do
      association = Role.reflect_on_association(:users)
      expect(association).not_to be_nil
      expect(association.macro).to eq(:has_and_belongs_to_many)
    end

    it 'can belong to a resource optionally' do
      association = Role.reflect_on_association(:resource)
      expect(association).not_to be_nil
      expect(association.macro).to eq(:belongs_to)
      expect(association.options[:polymorphic]).to be true
      expect(association.options[:optional]).to be true
    end
  end
end
