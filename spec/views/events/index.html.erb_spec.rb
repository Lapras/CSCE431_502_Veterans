# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'events/index', type: :view do
  let!(:events) do
    [
      Event.create!(
        title: 'Title',
        starts_at: 1.day.from_now,
        location: 'Location'
      ),
      Event.create!(
        title: 'Title',
        starts_at: 1.day.from_now,
        location: 'Location'
      )
    ]
  end

  before do
    assign(:events, events)
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
  end
end
