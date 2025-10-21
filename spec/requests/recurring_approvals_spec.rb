# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'RecurringApprovals', type: :request do
  let(:admin) { User.create!(email: 'admin@example.com') }
  let(:user) { User.create!(email: 'user@example.com') }
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

  before do
    admin.add_role(:admin)
    user.add_role(:member)
  end

  describe 'POST /recurring_excusals/:recurring_excusal_id/recurring_approvals' do
    context 'as admin' do
      before { sign_in admin }

      it 'creates an approval and updates recurring excusal' do
        expect do
          post recurring_excusal_recurring_approvals_path(recurring_excusal), params: {
            recurring_approval: { decision: 'approved', comment: 'Looks good' }
          }
        end.to change(RecurringApproval, :count).by(1)

        expect(recurring_excusal.reload.status).to eq('approved')
        expect(response).to redirect_to(approvals_path)
      end

      it 'denies a recurring excusal' do
        post recurring_excusal_recurring_approvals_path(recurring_excusal), params: {
          recurring_approval: { decision: 'denied', comment: 'Not valid' }
        }

        expect(recurring_excusal.reload.status).to eq('denied')
        expect(response).to redirect_to(approvals_path)
      end

      it 'prevents duplicate approvals' do
        RecurringApproval.create!(
          recurring_excusal: recurring_excusal,
          approved_by_user: admin,
          decision: 'approved',
          decision_at: Time.current
        )

        post recurring_excusal_recurring_approvals_path(recurring_excusal), params: {
          recurring_approval: { decision: 'denied' }
        }

        expect(flash[:alert]).to be_present
        expect(response).to redirect_to(approvals_path)
      end

      it 'handles not found recurring excusal' do
        post recurring_excusal_recurring_approvals_path(recurring_excusal_id: 999_999), params: {
          recurring_approval: { decision: 'approved' }
        }

        expect(flash[:alert]).to be_present
        expect(response).to redirect_to(approvals_path)
      end
    end

    context 'as non-admin' do
      before { sign_in user }

      it 'redirects to events path' do
        post recurring_excusal_recurring_approvals_path(recurring_excusal), params: {
          recurring_approval: { decision: 'approved' }
        }

        expect(response).to redirect_to(events_path)
      end
    end
  end
end
