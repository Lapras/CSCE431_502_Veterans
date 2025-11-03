# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AttendancesController, type: :controller do
  let(:admin) do
    user = User.create!(email: "admin#{SecureRandom.hex(4)}@example.com")
    user.add_role(:admin)
    user
  end

  let(:member) do
    user = User.create!(email: "member#{SecureRandom.hex(4)}@example.com")
    user.add_role(:member)
    user
  end

  let(:event) { Event.create!(title: 'Test Event', starts_at: 1.day.from_now, location: 'Test Location') }
  let(:attendance) { event.attendances.find_or_create_by!(user: member) { |a| a.status = 'pending' } }

  before do
    sign_in admin
  end

  describe 'GET #index' do
    it 'returns a success response' do
      get :index, params: { event_id: event.id }
      expect(response).to be_successful
    end

    it 'renders successfully with attendances' do
      attendance # create it
      get :index, params: { event_id: event.id }
      expect(response).to be_successful
    end

    it 'renders attendance stats successfully' do
      get :index, params: { event_id: event.id }
      expect(response).to be_successful
    end
  end

  describe 'GET #edit' do
    it 'returns a success response' do
      get :edit, params: { event_id: event.id, id: attendance.id }
      expect(response).to be_successful
    end
  end

  describe 'PATCH #update' do
    context 'with valid params' do
      it 'updates the attendance' do
        patch :update, params: { event_id: event.id, id: attendance.id, attendance: { status: 'present' } }
        expect(attendance.reload.status).to eq('present')
      end

      it 'redirects to the attendances index' do
        patch :update, params: { event_id: event.id, id: attendance.id, attendance: { status: 'present' } }
        expect(response).to redirect_to(event_attendances_path(event))
      end
    end

    context 'with invalid params' do
      it 'returns unprocessable_entity status' do
        allow_any_instance_of(Attendance).to receive(:update).and_return(false)
        patch :update, params: { event_id: event.id, id: attendance.id, attendance: { status: 'invalid' } }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'POST #check_in' do
    before do
      sign_in member
    end

    it 'checks in the current user with valid code' do
      post :check_in, params: { event_id: event.id, check_in_code: event.check_in_code }
      expect(member.reload.attendances.first.status).to eq('present')
    end

    it 'redirects to the event with valid code' do
      post :check_in, params: { event_id: event.id, check_in_code: event.check_in_code }
      expect(response).to redirect_to(event)
    end

    it 'creates attendance if not exists with valid code' do
      expect do
        post :check_in, params: { event_id: event.id, check_in_code: event.check_in_code }
      end.to change(Attendance, :count).by(1)
    end

    it 'does not check in with invalid code' do
      post :check_in, params: { event_id: event.id, check_in_code: '999' }
      expect(member.reload.attendances.first&.status).to eq('pending')
    end

    it 'redirects with alert on invalid code' do
      post :check_in, params: { event_id: event.id, check_in_code: '999' }
      expect(response).to redirect_to(event)
      expect(flash[:alert]).to eq(I18n.t('attendance.invalid_code'))
    end
  end

  describe 'POST #bulk_update' do
    let!(:attendance_1) { event.attendances.find_or_create_by!(user: member) { |a| a.status = 'pending' } }
    let!(:other_user) { User.create!(email: "other#{SecureRandom.hex(4)}@example.com") }
    let!(:attendance_2) { event.attendances.find_or_create_by!(user: other_user) { |a| a.status = 'pending' } }

    it 'updates multiple attendances' do
      post :bulk_update, params: {
        event_id: event.id,
        attendances: {
          attendance_1.id => { status: 'present' },
          attendance_2.id => { status: 'absent' }
        }
      }

      expect(attendance_1.reload.status).to eq('present')
      expect(attendance_2.reload.status).to eq('absent')
    end

    it 'redirects to event attendances path' do
      post :bulk_update, params: {
        event_id: event.id,
        attendances: {
          attendance_1.id => { status: 'present' }
        }
      }

      expect(response).to redirect_to(event_attendances_path(event))
    end
  end

  describe '#select_layout' do
    it 'returns admin layout for admin users' do
      sign_in admin
      get :index, params: { event_id: event.id }
      expect(controller.send(:select_layout)).to eq('admin')
    end

    it 'returns user layout for non-admin users' do
      sign_in member
      get :index, params: { event_id: event.id }
      expect(response).to have_http_status(:redirect) # non-admin redirected
    end
  end

  describe '#require_admin!' do
    context 'when user is not an admin' do
      before { sign_in member }

      it 'redirects to events_path for non-admin trying to access index' do
        get :index, params: { event_id: event.id }
        expect(response).to redirect_to(events_path)
      end

      it 'allows check_in for non-admin with valid code' do
        post :check_in, params: { event_id: event.id, check_in_code: event.check_in_code }
        expect(response).to redirect_to(event)
      end
    end
  end
end
