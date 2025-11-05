# frozen_string_literal: true

# spec/requests/discipline_records_spec.rb
require 'rails_helper'

RSpec.describe 'DisciplineRecords', type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let!(:record_1) { create(:discipline_record, user: user, given_by: user, points: 5) }
  let!(:record_2) { create(:discipline_record, user: other_user, given_by: other_user, points: 3) }

  before do
    sign_in user
    user.add_role(:member)
  end

  describe 'GET /discipline_records' do
    it 'returns a successful response' do
      get discipline_records_path
      expect(response).to have_http_status(:ok)
      # Only includes records belonging to the signed-in user
      expect(response.body).to include(record_1.reason)
      expect(response.body).not_to include(record_2.reason)
    end
  end

  describe 'GET /discipline_records/:id' do
    context 'when accessing own record' do
      it 'returns a successful response' do
        get discipline_record_path(record_1)
        expect(response).to have_http_status(:ok)
        expect(response.body).to include(record_1.reason)
      end
    end

    context "when accessing another user's record" do
      it 'redirects to root with an alert' do
        get discipline_record_path(record_2)

        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq('You are not authorized to access that page.')
      end
    end
  end
end
