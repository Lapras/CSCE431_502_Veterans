# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::DisciplineRecordsController, type: :controller do
  let(:admin) { create(:user, :admin) }
  let(:user) { create(:user) }
  let!(:record) { create(:discipline_record, user: user, given_by: admin) }

  before do
    sign_in admin
  end

  describe 'GET #index' do
    it 'returns a successful response' do
      get :index
      expect(response).to be_successful
      expect(assigns(:discipline_records)).to include(record)
    end
  end

  describe 'GET #new' do
    it 'renders the new template' do
      get :new
      expect(response).to render_template(:new)
      expect(assigns(:discipline_record)).to be_a_new(DisciplineRecord)
    end
  end

  describe 'POST #create' do
    it 'creates a new discipline record' do
      expect do
        post :create,
             params: { discipline_record: { user_id: user.id, given_by_id: admin.id, points: 5, reason: 'Test' } }
      end.to change(DisciplineRecord, :count).by(1)
    end

    it 'redirects to the admin discipline records index' do
      post :create,
           params: { discipline_record: { user_id: user.id, given_by_id: admin.id, points: 5, reason: 'Test' } }
      expect(response).to redirect_to(admin_discipline_records_path)
    end
  end

  describe 'GET #edit' do
    it 'renders the edit template' do
      get :edit, params: { id: record.id }
      expect(response).to render_template(:edit)
    end
  end

  describe 'PATCH #update' do
    it 'updates the record' do
      patch :update, params: { id: record.id, discipline_record: { points: 7 } }
      expect(record.reload.points).to eq(7)
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the record' do
      expect do
        delete :destroy, params: { id: record.id }
      end.to change(DisciplineRecord, :count).by(-1)
    end
  end
end
