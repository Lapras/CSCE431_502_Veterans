# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::DisciplineRecordsController, type: :controller do
  let(:admin) { create(:user, :admin) }
  let(:user) { create(:user, :member) }
  let!(:record) { create(:discipline_record, user: user, given_by: admin) }

  before { sign_in admin }

  describe 'GET #index' do
    it 'returns a successful response with all records' do
      get :index
      expect(response).to be_successful
      expect(assigns(:discipline_records)).to include(record)
      expect(response).to render_template(:index)
    end
  end

  describe 'GET #new' do
    it 'renders the new template' do
      get :new
      expect(response).to be_successful
      expect(assigns(:discipline_record)).to be_a_new(DisciplineRecord)
      expect(response).to render_template(:new)
    end
  end

  describe 'POST #create' do
    context 'with valid parameters' do
      let(:valid_params) do
        { discipline_record: { user_id: user.id, record_type: 'tardy', reason: 'Test reason' } }
      end

      it 'creates a new discipline record' do
        expect do
          post :create, params: valid_params
        end.to change(DisciplineRecord, :count).by(1)
      end

      it 'redirects to the index with a notice' do
        post :create, params: valid_params
        expect(response).to redirect_to(admin_discipline_records_path)
        expect(flash[:notice]).to eq(I18n.t('discipline_records.created'))
      end
    end

    context 'with invalid parameters' do
      let(:invalid_params) do
        { discipline_record: { user_id: nil, record_type: 'tardy', reason: '' } }
      end

      it 'does not create a record and re-renders new with unprocessable_entity' do
        expect do
          post :create, params: invalid_params
        end.not_to change(DisciplineRecord, :count)

        expect(response).to render_template(:new)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'GET #edit' do
    it 'renders the edit template' do
      get :edit, params: { id: record.id }
      expect(response).to be_successful
      expect(assigns(:discipline_record)).to eq(record)
      expect(response).to render_template(:edit)
    end
  end

  describe 'PATCH #update' do
    context 'with valid parameters' do
      let(:valid_update_params) do
        { discipline_record: { record_type: 'absence', reason: 'Updated reason' } }
      end

      it 'updates the record and redirects to show' do
        patch :update, params: { id: record.id }.merge(valid_update_params)
        record.reload
        expect(record.record_type).to eq('absence')
        expect(record.reason).to eq('Updated reason')
        expect(response).to redirect_to(admin_discipline_record_path(record))
        expect(flash[:notice]).to eq(I18n.t('discipline_records.update'))
      end
    end

    context 'with invalid parameters' do
      let(:invalid_update_params) do
        { discipline_record: { record_type: record.record_type, reason: '' } }
      end

      it 'does not update and re-renders edit with unprocessable_entity' do
        patch :update, params: { id: record.id }.merge(invalid_update_params)
        record.reload
        expect(record.reason).not_to eq('')
        expect(response).to render_template(:edit)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the record and redirects to index' do
      expect do
        delete :destroy, params: { id: record.id }
      end.to change(DisciplineRecord, :count).by(-1)
      expect(response).to redirect_to(admin_discipline_records_path)
      expect(flash[:notice]).to eq(I18n.t('discipline_records.deleted'))
    end
  end

  describe 'authorization' do
    context 'when a non-admin user is signed in' do
      before do
        sign_out admin
        sign_in user
      end

      it 'redirects to root with not authorized alert' do
        get :index
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq(I18n.t('alerts.not_authorized'))
      end
    end
  end
end
