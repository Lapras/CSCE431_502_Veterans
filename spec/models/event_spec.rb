# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Role gate', type: :request do
  before do
    allow_any_instance_of(ApplicationController).to receive(:authenticate_user!).and_return(true)
  end

  it 'redirects to /not_a_member when current_user has no roles' do
    user = double('User', roles: [], has_role?: false)
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)

    get events_url
    expect(response).to redirect_to('/not_a_member')
  end

  it 'allows through when current_user has at least one role' do
    user = double('User', roles: [double('Role')], has_role?: true)
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)

    get events_url
    expect(response).to be_successful
  end

  it "does NOT add the 'in the past' error when starts_at is blank (only presence error)" do
    e = Event.new(title: "T", location: "L", starts_at: nil)
    expect(e).not_to be_valid
    # Presence validator fires:
    expect(e.errors[:starts_at]).to include("can't be blank")
    # Custom validator returns early (no 'in the past' message):
    expect(e.errors[:starts_at]).not_to include("can't be in the past")
  end

  it "adds 'is not a valid datetime' when starts_at is present but not a Time/TimeWithZone" do
    e = Event.new(title: "T", location: "L")
    # Make starts_at 'present' yet not a Time/TimeWithZone
    allow(e).to receive(:starts_at).and_return("not-a-time")
    e.validate
    expect(e.errors[:starts_at]).to include("is not a valid datetime")
    expect(e.errors[:starts_at]).not_to include("can't be blank")
  end
end
