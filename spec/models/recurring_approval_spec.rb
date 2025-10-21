# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RecurringApproval, type: :model do
  let(:user) { User.create!(email: 'user@example.com') }
  let(:admin) { User.create!(email: 'admin@example.com') }
  let(:recurring_excusal) do
    RecurringExcusal.create!(
      user: user,
      reason: 'Test reason',
      recurring_days: %w[Monday Wednesday],
      recurring_start_time: '09:00',
      recurring_end_time: '10:00',
      status: 'pending'
    )
  end

  describe 'associations' do
    it 'belongs to recurring_excusal' do
      approval = RecurringApproval.new
      expect(approval).to respond_to(:recurring_excusal)
    end

    it 'belongs to approved_by_user' do
      approval = RecurringApproval.new
      expect(approval).to respond_to(:approved_by_user)
    end
  end

  describe 'validations' do
    it 'validates presence of decision' do
      approval = RecurringApproval.new(recurring_excusal: recurring_excusal, approved_by_user: admin,
                                       decision_at: Time.current)
      expect(approval).not_to be_valid
      expect(approval.errors[:decision]).to include("can't be blank")
    end

    it 'validates presence of decision_at' do
      approval = RecurringApproval.new(recurring_excusal: recurring_excusal, approved_by_user: admin,
                                       decision: 'approved')
      expect(approval).not_to be_valid
      expect(approval.errors[:decision_at]).to include("can't be blank")
    end

    it 'validates decision is either approved or denied' do
      approval = RecurringApproval.new(recurring_excusal: recurring_excusal, approved_by_user: admin,
                                       decision: 'invalid', decision_at: Time.current)
      expect(approval).not_to be_valid
    end

    it 'validates uniqueness of recurring_excusal_id' do
      RecurringApproval.create!(
        recurring_excusal: recurring_excusal,
        approved_by_user: admin,
        decision: 'approved',
        decision_at: Time.current
      )
      duplicate = RecurringApproval.new(
        recurring_excusal: recurring_excusal,
        approved_by_user: admin,
        decision: 'denied',
        decision_at: Time.current
      )
      expect(duplicate).not_to be_valid
    end
  end

  describe 'scopes' do
    let!(:approved_approval) do
      RecurringApproval.create!(
        recurring_excusal: recurring_excusal,
        approved_by_user: admin,
        decision: 'approved',
        decision_at: Time.current
      )
    end

    let!(:denied_approval) do
      recurring_2 = RecurringExcusal.create!(
        user: user,
        reason: 'Another reason',
        recurring_days: ['Tuesday'],
        recurring_start_time: '09:00',
        recurring_end_time: '10:00',
        status: 'pending'
      )
      RecurringApproval.create!(
        recurring_excusal: recurring_2,
        approved_by_user: admin,
        decision: 'denied',
        decision_at: Time.current
      )
    end

    it 'returns approved approvals' do
      expect(RecurringApproval.approved).to include(approved_approval)
      expect(RecurringApproval.approved).not_to include(denied_approval)
    end

    it 'returns denied approvals' do
      expect(RecurringApproval.denied).to include(denied_approval)
      expect(RecurringApproval.denied).not_to include(approved_approval)
    end
  end

  describe 'callbacks' do
    it 'updates recurring excusal status after create' do
      RecurringApproval.create!(
        recurring_excusal: recurring_excusal,
        approved_by_user: admin,
        decision: 'approved',
        decision_at: Time.current
      )
      expect(recurring_excusal.reload.status).to eq('approved')
    end
  end
end
