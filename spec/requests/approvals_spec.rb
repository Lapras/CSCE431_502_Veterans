require 'rails_helper'

RSpec.describe "Approvals", type: :request do
  let(:admin) { User.create!(email: 'admin@example.com') }
  let(:user) { User.create!(email: 'user@example.com') }
  let(:event) { Event.create!(title: 'Test Event', starts_at: 1.day.from_now, location: 'Test Location') }
  let(:excusal_request) { ExcusalRequest.create!(user: user, event: event, reason: 'Test reason', status: 'pending') }

  before do
    admin.add_role(:admin)
    user.add_role(:member)
  end

  describe "GET /approvals" do
    context "as admin" do
      before { sign_in admin }

      it "returns success" do
        get approvals_path
        expect(response).to be_successful
      end
    end

    context "as non-admin" do
      before { sign_in user }

      it "redirects to events path" do
        get approvals_path
        expect(response).to redirect_to(events_path)
      end
    end
  end

  describe "POST /excusal_requests/:excusal_request_id/approvals" do
    context "as admin" do
      before { sign_in admin }

      it "creates an approval and updates excusal request" do
        expect {
          post excusal_request_approvals_path(excusal_request), params: {
            approval: { decision: 'approved', comment: 'Looks good' }
          }
        }.to change(Approval, :count).by(1)

        expect(excusal_request.reload.status).to eq('approved')
        expect(response).to redirect_to(approvals_path)
      end

      it "denies an excusal request" do
        post excusal_request_approvals_path(excusal_request), params: {
          approval: { decision: 'denied', comment: 'Not valid' }
        }

        expect(excusal_request.reload.status).to eq('denied')
        expect(response).to redirect_to(approvals_path)
      end

      it "prevents duplicate approvals" do
        Approval.create!(
          excusal_request: excusal_request,
          approved_by_user: admin,
          decision: 'approved',
          decision_at: Time.current
        )

        post excusal_request_approvals_path(excusal_request), params: {
          approval: { decision: 'denied' }
        }

        expect(flash[:alert]).to be_present
        expect(response).to redirect_to(approvals_path)
      end

      it "handles not found excusal request" do
        post excusal_request_approvals_path(excusal_request_id: 999999), params: {
          approval: { decision: 'approved' }
        }

        expect(flash[:alert]).to be_present
        expect(response).to redirect_to(approvals_path)
      end
    end

    context "as non-admin" do
      before { sign_in user }

      it "redirects to events path" do
        post excusal_request_approvals_path(excusal_request), params: {
          approval: { decision: 'approved' }
        }

        expect(response).to redirect_to(events_path)
      end
    end
  end
end
