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

  it 'renders a list of events with titles, locations, and formatted start times' do
    render

    # Check that each event's unique title and location appears
    expect(rendered).to have_text('Event One')
    expect(rendered).to have_text('Event Two')
    expect(rendered).to have_text('Location One')
    expect(rendered).to have_text('Location Two')

    # Check that "Starts at:" label appears for each event
    expect(rendered).to have_text('Starts at:').twice
  end
end
