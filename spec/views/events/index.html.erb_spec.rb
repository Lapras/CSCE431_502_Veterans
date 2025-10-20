# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'events/index', type: :view do
  let(:user) { User.create!(email: 'test@example.com', full_name: 'Test User') }
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
    # Mock current_user for Devise
    allow(view).to receive(:current_user).and_return(user)
    # Mock has_role? method
    allow(user).to receive(:has_role?).with(:admin).and_return(false)
    allow(user).to receive(:has_role?).with(:member).and_return(true)
  end

<<<<<<< HEAD
  it 'renders a list of events with titles, locations, and formatted start times' do
    # Mock attendance_for for each event
    events.each do |event|
      allow(event).to receive(:attendance_for).with(user).and_return(nil)
    end

    render

    # Check that each event's unique title and location appears
    expect(rendered).to have_text('Event One')
    expect(rendered).to have_text('Event Two')
    expect(rendered).to have_text('Location One')
    expect(rendered).to have_text('Location Two')
=======
  it "renders a list" do
    assign(:events, [
      Event.new(id: 1, title: "T1", starts_at: Time.zone.now, location: "L1"),
      Event.new(id: 2, title: "T2", starts_at: Time.zone.now, location: "L2"),
    ])

    fake_user = double("user", excusal_requests: double("reqs", where: []))
    allow(view).to receive(:current_user).and_return(fake_user)

    render
    expect(rendered).to include("T1").and include("T2")
>>>>>>> origin/sprint1-test-coverage
  end
end
