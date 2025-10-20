# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Approvals', type: :request do
  before do
    # Skip Devise
    allow_any_instance_of(ApplicationController)
        .to receive(:authenticate_user!).and_return(true)
    
    # Create REAL users with roles
    @admin_user = User.create!(
        full_name: "Admin User",
        email: "admin@test.com",
        uid: "admin123"
    )
    @admin_user.add_role(:admin)
    
    # Set current_user to the real admin
    allow_any_instance_of(ApplicationController)
        .to receive(:current_user).and_return(@admin_user)
    
    # Bypass the "not_a_member" check
    allow_any_instance_of(ApplicationController)
        .to receive(:check_user_roles).and_return(true)
  end

  describe 'GET /approvals' do
    let!(:user) { User.create!(email: 'student@test.com', full_name: 'Test Student') }
    let!(:event) { Event.create!(title: 'Test Event', starts_at: 1.day.from_now, location: 'Test Location') }
    
    context 'with pending excusal requests' do
      let!(:pending_request) do
        ExcusalRequest.create!(
          user: user,
          event: event,
          reason: 'I have a doctor appointment',
          status: 'pending'
        )
      end

      it 'displays pending excusal requests' do
        get approvals_path
        expect(response).to have_http_status(:success)
        expect(response.body).to include('Test Student')
        expect(response.body).to include('Test Event')
        expect(response.body).to include('I have a doctor appointment')
      end
    end

    context 'with pending recurring excusals' do
      let!(:pending_recurring) do
        RecurringExcusal.create!(
          user: user,
          reason: 'Weekly therapy',
          recurring_days: [1, 3], # Monday and Wednesday
          recurring_start_time: '14:00',
          recurring_end_time: '15:00',
          status: 'pending'
        )
      end

      it 'displays pending recurring excusals' do
        get approvals_path
        expect(response).to have_http_status(:success)
        expect(response.body).to include('Test Student')
        expect(response.body).to include('Weekly therapy')
        expect(response.body).to include('Monday')
        expect(response.body).to include('Wednesday')
      end
    end

    context 'with approved requests' do
      let!(:approved_request) do
        request = ExcusalRequest.create!(
          user: user,
          event: event,
          reason: 'Family emergency',
          status: 'approved'
        )
        Approval.create!(
          excusal_request: request,
          approved_by_user_id: @admin_user.id,
          decision: 'approved',
          decision_at: Time.current,
          comment: 'Approved due to valid reason'
        )
        request
      end

      it 'displays approved requests in the approved section' do
        get approvals_path
        expect(response).to have_http_status(:success)
        expect(response.body).to include('Family emergency')
        expect(response.body).to include('Approved due to valid reason')
      end
    end

    context 'with denied requests' do
      let!(:denied_request) do
        request = ExcusalRequest.create!(
          user: user,
          event: event,
          reason: 'Just because',
          status: 'denied'
        )
        Approval.create!(
          excusal_request: request,
          approved_by_user_id: @admin_user.id,
          decision: 'denied',
          decision_at: Time.current,
          comment: 'Insufficient reason provided'
        )
        request
      end

      it 'displays denied requests in the denied section' do
        get approvals_path
        expect(response).to have_http_status(:success)
        expect(response.body).to include('Just because')
        expect(response.body).to include('Insufficient reason provided')
      end
    end
  end

  describe 'POST /excusal_requests/:excusal_request_id/approvals' do
    let!(:user) { User.create!(email: 'student@test.com', full_name: 'Test Student') }
    let!(:event) { Event.create!(title: 'Test Event', starts_at: 1.day.from_now, location: 'Test Location') }
    let!(:excusal_request) do
      ExcusalRequest.create!(
        user: user,
        event: event,
        reason: 'Need to miss event',
        status: 'pending'
      )
    end

    context 'approving an excusal request' do
      it 'creates an approval and updates the request status' do
        expect do
          post excusal_request_approvals_path(excusal_request), params: {
            approval: {
              decision: 'approved',
              comment: 'Valid reason provided'
            }
          }
        end.to change(Approval, :count).by(1)

        expect(response).to redirect_to(approvals_path)
        expect(flash[:notice]).to eq('Excusal request approved.')
        
        excusal_request.reload
        expect(excusal_request.status).to eq('approved')
        expect(excusal_request.approval.comment).to eq('Valid reason provided')
      end
    end

    context 'denying an excusal request' do
      it 'creates an approval with denied decision' do
        post excusal_request_approvals_path(excusal_request), params: {
          approval: {
            decision: 'denied',
            comment: 'Insufficient documentation'
          }
        }

        expect(response).to redirect_to(approvals_path)
        expect(flash[:notice]).to eq('Excusal request denied.')
        
        excusal_request.reload
        expect(excusal_request.status).to eq('denied')
      end
    end

    context 'when request already has an approval' do
      before do
        Approval.create!(
          excusal_request: excusal_request,
          approved_by_user_id: @admin_user.id,
          decision: 'approved',
          decision_at: Time.current
        )
      end

      it 'does not create a duplicate approval' do
        expect do
          post excusal_request_approvals_path(excusal_request), params: {
            approval: {
              decision: 'approved',
              comment: 'Second approval attempt'
            }
          }
        end.not_to change(Approval, :count)

        expect(response).to redirect_to(approvals_path)
        expect(flash[:alert]).to eq('This request has already been reviewed.')
      end
    end

    context 'with invalid approval data' do
      it 'handles missing decision' do
        post excusal_request_approvals_path(excusal_request), params: {
          approval: {
            decision: '',
            comment: 'Some comment'
          }
        }

        expect(response).to redirect_to(approvals_path)
        expect(flash[:alert]).to include('Error processing approval')
      end
    end
  end
end