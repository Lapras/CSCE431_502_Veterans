# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'events/index', type: :view do
  let!(:events) do
    [
      Event.create!(
        title: 'Event One',
        starts_at: 1.day.from_now,
        location: 'Location One'
      ),
      Event.create!(
        title: 'Event Two',
        starts_at: 2.days.from_now,
        location: 'Location Two'
      )
    ]
  end

  before do
    assign(:events, events)
    # Stub helper method that's used in the view
    allow(view).to receive(:user_excusal_requests_for).and_return([])
  end

  it "renders a list" do
    assign(:events, [
      Event.new(id: 1, title: "T1", starts_at: Time.zone.now, location: "L1"),
      Event.new(id: 2, title: "T2", starts_at: Time.zone.now, location: "L2"),
    ])

    fake_user = double("user", excusal_requests: double("reqs", where: []))
    allow(view).to receive(:current_user).and_return(fake_user)

    render

    expect(rendered).to include("T1").and include("T2")
    expect(rendered).to include("L1").and include("L2")
    expect(rendered).to have_text('Starts at:').twice
  end
end
