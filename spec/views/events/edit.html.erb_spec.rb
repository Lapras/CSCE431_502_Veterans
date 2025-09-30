require 'rails_helper'

RSpec.describe "events/edit", type: :view do
  let(:event) {
    Event.create!(
      title: "My Concert",
      starts_at: DateTime.new(2025, 10, 1, 19, 30),
      location: "New York"
    )
  }

  before(:each) do
    assign(:event, event)
  end

  it "renders the edit event form with all fields and submit button" do
    render

    assert_select "form[action=?][method=?]", event_path(event), "post" do
      assert_select "input[name=?][value=?]", "event[title]", "My Concert"
      assert_select "input[name=?][value=?]", "event[location]", "New York"
      assert_select "input[name=?]", "event[starts_at]"
      assert_select "input[type=?]", "submit"
    end
  end
end
