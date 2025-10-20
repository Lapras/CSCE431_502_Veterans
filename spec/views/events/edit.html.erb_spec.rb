# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'events/edit', type: :view do
  it 'renders the edit event form with all fields and submit button' do
    # Use a future date to pass validation
    event = Event.create!(
      title: 'My Concert',
      starts_at: 2.days.from_now,
      location: 'New York'
    )

    assign(:event, event)

    render

    assert_select 'form[action=?][method=?]', event_path(event), 'post' do
      assert_select 'input[name=?]', 'event[title]'
      assert_select 'input[name=?]', 'event[starts_at]'
      assert_select 'input[name=?]', 'event[location]'
      assert_select 'input[type=?][value=?]', 'submit', 'Update Event'
    end
  end
end
