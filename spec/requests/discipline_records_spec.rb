require 'rails_helper'

RSpec.describe 'users/show.html.erb', type: :view do
  let(:user) { create(:user) }
  let!(:discipline_record) { create(:discipline_record, user: user) }

  before do
    assign(:user, user)
    render
  end

  it "displays the user's discipline records" do
    expect(rendered).to match(discipline_record.reason)
    expect(rendered).to match(discipline_record.points.to_s)
  end
end
