require 'rails_helper'

RSpec.describe "events/edit", type: :view do
  let(:event) {
    Event.create!(
      title: "MyString",
      starts_at: 1.day.from_now,
      location: "MyString"
    )
  }

  before(:each) do
    assign(:event, event)
  end

  it "renders the edit event form" do
    render

    assert_select "form[action=?][method=?]", event_path(event), "post" do

      assert_select "input[name=?]", "event[title]"

      assert_select "input[name=?]", "event[location]"
    end
  end
end
