# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Approval, type: :model do
  let(:user) { User.create!(email: 'user@example.com') }
  let(:admin) { User.create!(email: 'admin@example.com') }
  let(:event) { Event.create!(title: 'Test Event', starts_at: 1.day.from_now, location: 'Test Location') }
  let(:excusal_request) { ExcusalRequest.create!(user: user, event: event, reason: 'Test reason') }

  describe 'associations' do
    it 'belongs to excusal_request' do
      approval = Approval.new
      expect(approval).to respond_to(:excusal_request)
    end

    it 'belongs to approved_by_user' do
      approval = Approval.new
      expect(approval).to respond_to(:approved_by_user)
    end
  end

  describe 'validations' do
    it 'validates presence of decision' do
      approval = Approval.new(excusal_request: excusal_request, approved_by_user: admin, decision_at: Time.current)
      expect(approval).not_to be_valid
      expect(approval.errors[:decision]).to include("can't be blank")
    end

    it 'validates presence of decision_at' do
      approval = Approval.new(excusal_request: excusal_request, approved_by_user: admin, decision: 'approved')
      expect(approval).not_to be_valid
      expect(approval.errors[:decision_at]).to include("can't be blank")
    end

    it 'validates decision is either approved or denied' do
      approval = Approval.new(excusal_request: excusal_request, approved_by_user: admin, decision: 'invalid',
                              decision_at: Time.current)
      expect(approval).not_to be_valid
    end

    it 'validates uniqueness of excusal_request_id' do
      Approval.create!(
        excusal_request: excusal_request,
        approved_by_user: admin,
        decision: 'approved',
        decision_at: Time.current
      )
      duplicate = Approval.new(
        excusal_request: excusal_request,
        approved_by_user: admin,
        decision: 'denied',
        decision_at: Time.current
      )
      expect(duplicate).not_to be_valid
    end
  end

  describe 'scopes' do
    let!(:approved_approval) do
      Approval.create!(
        excusal_request: excusal_request,
        approved_by_user: admin,
        decision: 'approved',
        decision_at: Time.current
      )
    end

    let!(:denied_approval) do
      excusal2 = ExcusalRequest.create!(user: user, event: event, reason: 'Another reason')
      Approval.create!(
        excusal_request: excusal2,
        approved_by_user: admin,
        decision: 'denied',
        decision_at: Time.current
      )
    end

    it 'returns approved approvals' do
      expect(Approval.approved).to include(approved_approval)
      expect(Approval.approved).not_to include(denied_approval)
    end

    it 'returns denied approvals' do
      expect(Approval.denied).to include(denied_approval)
      expect(Approval.denied).not_to include(approved_approval)
    end
  end

  describe 'callbacks' do
    it 'updates excusal request status after create' do
      Approval.create!(
        excusal_request: excusal_request,
        approved_by_user: admin,
        decision: 'approved',
        decision_at: Time.current
      )
      expect(excusal_request.reload.status).to eq('approved')
    end
  end
end
