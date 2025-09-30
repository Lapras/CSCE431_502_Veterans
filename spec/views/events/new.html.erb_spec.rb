require 'rails_helper'

RSpec.describe "events/new", type: :view do
  before(:each) do
    assign(:event, Event.new(
      title: "",
      starts_at: nil,
      location: ""
    ))
  end

  it "renders new event form with all fields and submit button" do
    render

    assert_select "form[action=?][method=?]", events_path, "post" do
      assert_select "input[name=?]", "event[title]"
      assert_select "input[name=?]", "event[starts_at]"
      assert_select "input[name=?]", "event[location]"
      assert_select "input[type=?]", "submit"
    end
  end
end
