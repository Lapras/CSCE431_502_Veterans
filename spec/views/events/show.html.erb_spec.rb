require 'rails_helper'

RSpec.describe "events/show", type: :view do
  let(:event) {
    Event.create!(
      title: "Title",
      starts_at: 1.day.from_now,
      location: "Location"
    )
  }

  before(:each) do
    assign(:event, event)
  end

  it "renders event attributes in <p> tags" do
    render

    expect(rendered).to have_selector('p', text: event.title)
    expect(rendered).to have_selector('p', text: event.location)

    formatted_date = event.starts_at.strftime("%Y-%m-%d %H:%M:%S %Z")
    expect(rendered).to have_selector('p', text: formatted_date)
  end
end
