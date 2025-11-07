# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'admin/users/index', type: :view do
  let(:member_user) { create(:user, :member) }
  let(:admin_user)  { create(:user, :admin) }

  before do
    assign(:users, [member_user, admin_user])
    # Sign in as an admin so current_user is available in the view
    allow(view).to receive(:current_user).and_return(admin_user)
  end

  it 'renders a list of users' do
    render

    expect(rendered).to include(member_user.email)
    expect(rendered).to include(admin_user.email)
  end
end
