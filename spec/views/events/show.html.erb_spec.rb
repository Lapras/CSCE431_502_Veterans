# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'events/show', type: :view do
  let(:user) { User.create!(email: 'test@example.com', full_name: 'Test User') }
  let(:event) do
    Event.create!(
      title: 'Title',
      starts_at: 1.day.from_now,
      location: 'Location'
    )
  end

  before(:each) do
    assign(:event, event)
    # Stub current_user for Devise
    allow(view).to receive(:current_user).and_return(user)
  end

  it 'renders event attributes in <p> tags' do
    render

    expect(rendered).to have_selector('h1', text: event.title)
    expect(rendered).to have_text(event.location)

    formatted_date = event.starts_at.strftime('%B %d, %Y at %I:%M %p')
    expect(rendered).to have_text(formatted_date)
  end
end
