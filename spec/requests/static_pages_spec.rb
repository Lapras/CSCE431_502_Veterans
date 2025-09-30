# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'StaticPages', type: :request do
  describe 'GET /not_a_member' do
    it 'returns http success' do
      get not_a_member_path
      expect(response).to have_http_status(:success)
    end
  end
end
