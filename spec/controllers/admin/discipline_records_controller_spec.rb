# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::DisciplineRecordsController, type: :controller do
  let(:admin) { create(:user, :admin) }
  let(:user) { create(:user, :member) }
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
    context 'with valid parameters' do
      it 'creates a new discipline record' do
        expect do
          post :create,
               params: { id: record.id, discipline_record: { record_type: 'invalid_enum_value' } }
        end.to change(DisciplineRecord, :count).by(1)
      end

      it 'redirects to the admin discipline records index' do
        post :create,
             params: { id: record.id, discipline_record: { record_type: 'invalid_enum_value' } }
        expect(response).to redirect_to(admin_discipline_records_path)
      end
    end

    context 'with invalid parameters' do
      it 'does not create a record and re-renders new with unprocessable_entity' do
        expect do
          post :create,
               params: { id: record.id, discipline_record: { record_type: 'invalid_enum_value' } }
        end.not_to change(DisciplineRecord, :count)

        expect(response).to render_template(:new)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'GET #edit' do
    it 'renders the edit template' do
      get :edit, params: { id: record.id }
      expect(response).to render_template(:edit)
    end
  end

  describe 'PATCH #update' do
    context 'with valid parameters' do
       it 'updates the record' do
        new_attrs = attributes_for(:discipline_record, record_type: 'absence', reason: 'Updated reason')

        patch :update, params: { id: record.id, discipline_record: new_attrs }

        expect(response).to redirect_to(admin_discipline_record_path(record))
        record.reload
        expect(record.record_type).to eq('absence')
        expect(record.reason).to eq('Updated reason')
      end
    end

    context 'with invalid parameters' do
      it 'does not update and re-renders edit with unprocessable_entity' do
        patch :update, params: { id: record.id, discipline_record: { record_type: record.record_type, reason: '' } }
        expect(response).to render_template(:edit)
        expect(response).to have_http_status(:unprocessable_entity)
        expect(record.reload.record_type).not_to be_nil
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the record' do
      expect do
        delete :destroy, params: { id: record.id }
      end.to change(DisciplineRecord, :count).by(-1)
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
