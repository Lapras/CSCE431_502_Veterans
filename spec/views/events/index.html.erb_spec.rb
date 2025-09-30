require 'rails_helper'

RSpec.describe "events/index", type: :view do
  let!(:events) do
    [
      Event.create!(
        title: "Title",
        starts_at: 1.day.from_now,
        location: "Location"
      ),
      Event.create!(
        title: "Title",
        starts_at: 1.day.from_now,
        location: "Location"
      )
    ]
  end

  before do
    assign(:events, events)
  end

  it "renders a list of events with titles, locations, and formatted start times" do
    render

    events.each do |event|
      assert_select 'div>p', text: Regexp.new(Regexp.escape(event.title)), count: 2
    end

    events.each do |event|
      assert_select 'div>p', text: Regexp.new(Regexp.escape(event.location)), count: 2
    end

    events.each do |event|
      formatted_date = event.starts_at.strftime("%Y-%m-%d %H:%M:%S %Z")
      assert_select 'div>p', text: Regexp.new(Regexp.escape(formatted_date)), count: 2
    end
  end
end
