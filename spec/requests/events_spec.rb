require 'rails_helper'

RSpec.describe "/events", type: :request do
  before do
    # Bypass Devise authentication for all tests in this block
    allow_any_instance_of(ApplicationController).to receive(:authenticate_user!).and_return(true)
    # Bypass admin check for controller actions that require admin
    allow_any_instance_of(EventsController).to receive(:require_admin!).and_return(true)
  end
  let(:valid_attributes) {
    {
      title: 'Concert',
      starts_at: 1.day.from_now,
      location: 'Texas'
    }
  }

  let(:invalid_attributes) {
    {
      title: '',
      starts_at: 1.day.ago,
      location: nil
    }
  }

  let(:new_attributes) {
    {
      title: 'Updated Concert',
      starts_at: 2.days.from_now,
      location: 'New York'
    }
  }

  describe "GET /index" do
    it "renders a successful response" do
      Event.create! valid_attributes
      get events_url
      expect(response).to be_successful
    end
  end

  describe "GET /show" do
    it "renders a successful response" do
      event = Event.create! valid_attributes
      get event_url(event)
      expect(response).to be_successful
    end
  end

  describe "GET /new" do
    it "renders a successful response" do
      get new_event_url
      expect(response).to be_successful
    end
  end

  describe "GET /edit" do
    it "renders a successful response" do
      event = Event.create! valid_attributes
      get edit_event_url(event)
      expect(response).to be_successful
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new Event" do
        expect {
          post events_url, params: { event: valid_attributes }
        }.to change(Event, :count).by(1)
      end

      it "redirects to the created event" do
        post events_url, params: { event: valid_attributes }
        expect(response).to redirect_to(event_url(Event.last))
      end
    end

    context "with invalid parameters" do
      it "does not create a new Event" do
        expect {
          post events_url, params: { event: invalid_attributes }
        }.to change(Event, :count).by(0)
      end

      it "renders a response with 422 status (unprocessable_entity)" do
        post events_url, params: { event: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "PATCH /update" do
    context "with valid parameters" do
      it "updates the requested event" do
        event = Event.create! valid_attributes
        patch event_url(event), params: { event: new_attributes }
        event.reload
        expect(event.title).to eq('Updated Concert')
        expect(event.location).to eq('New York')
        expect(event.starts_at.to_i).to eq(new_attributes[:starts_at].to_i)
      end

      it "redirects to the event" do
        event = Event.create! valid_attributes
        patch event_url(event), params: { event: new_attributes }
        expect(response).to redirect_to(event_url(event))
      end
    end

    context "with invalid parameters" do
      it "renders a response with 422 status (unprocessable_entity)" do
        event = Event.create! valid_attributes
        patch event_url(event), params: { event: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "GET /event_confirm_delete" do
    it "renders the confirmation delete page" do
      event = Event.create!(valid_attributes)
      get event_confirm_delete_event_path(event)
      expect(response).to be_successful
      expect(response.body).to include("Are you sure you want to delete this event?")
      expect(response.body).to include(event.title)
    end

  end

  describe "DELETE /destroy" do
    it "destroys the requested event" do
      event = Event.create! valid_attributes
      expect {
        delete event_url(event)
      }.to change(Event, :count).by(-1)
    end

    it "redirects to the events list" do
      event = Event.create! valid_attributes
      delete event_url(event)
      expect(response).to redirect_to(events_url)
    end
  end
end
