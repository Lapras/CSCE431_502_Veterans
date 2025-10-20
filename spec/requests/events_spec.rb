# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/events', type: :request do
  before do
    # Skip Devise
    allow_any_instance_of(ApplicationController)
      .to receive(:authenticate_user!).and_return(true)

    # Pretend the user is signed in and already has at least one role
    # so ApplicationController#check_user_roles doesn't redirect.
    stubbed_user = double('User', has_role?: true, roles: [double('Role')])
    allow_any_instance_of(ApplicationController)
      .to receive(:current_user).and_return(stubbed_user)

    # Completely bypass the "kick to /not_a_member" check for most tests
    allow_any_instance_of(ApplicationController)
      .to receive(:check_user_roles).and_return(true)

    # Bypass admin guard for tests that aren't about admin behavior
    allow_any_instance_of(EventsController)
      .to receive(:require_admin!).and_return(true)
  end
  let(:valid_attributes) do
    {
      title: 'Concert',
      starts_at: 1.day.from_now,
      location: 'Texas'
    }
  end

  let(:invalid_attributes) do
    {
      title: '',
      starts_at: 1.day.ago,
      location: nil
    }
  end

  let(:new_attributes) do
    {
      title: 'Updated Concert',
      starts_at: 2.days.from_now,
      location: 'New York'
    }
  end

  describe 'GET /index' do
    it 'renders a successful response' do
      Event.create!(valid_attributes)
      get events_url
      expect(response).to be_successful
    end

    it 'only shows events starting in the future' do
      future = Event.create!(title: 'Future', starts_at: 1.day.from_now, location: 'TX')
      past   = Event.new(title: 'Past', starts_at: 1.day.ago, location: 'TX')
      past.save!(validate: false)

      get events_url
      expect(response).to be_successful
      expect(response.body).to include(future.title)
      expect(response.body).not_to include(past.title)
    end
  end

  describe 'GET /index filters out past events' do
    it 'only returns future events' do
      Event.create!(title: 'Future', starts_at: 1.day.from_now, location: 'TX')
      past = Event.new(title: 'Past', starts_at: 1.day.ago, location: 'TX')
      past.save!(validate: false)

      get events_url
      expect(response).to be_successful
      expect(response.body).to include('Future')
      expect(response.body).not_to include('Past')
    end
  end

  describe 'GET /show' do
    it 'renders a successful response' do
      event = Event.create! valid_attributes
      get event_url(event)
      expect(response).to be_successful
    end
  end

  describe 'GET /new' do
    it 'renders a successful response' do
      get new_event_url
      expect(response).to be_successful
    end
  end

  describe 'GET /edit' do
    it 'renders a successful response' do
      event = Event.create! valid_attributes
      get edit_event_url(event)
      expect(response).to be_successful
    end
  end

  describe 'POST /create' do
    context 'with valid parameters' do
      it 'creates a new Event' do
        expect do
          post events_url, params: { event: valid_attributes }
        end.to change(Event, :count).by(1)
      end

      it 'redirects to the created event' do
        post events_url, params: { event: valid_attributes }
        expect(response).to redirect_to(event_url(Event.last))
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new Event' do
        expect do
          post events_url, params: { event: invalid_attributes }
        end.to change(Event, :count).by(0)
      end

      it 'renders a response with 422 status (unprocessable_entity)' do
        post events_url, params: { event: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'POST /create (JSON)' do
    it 'creates a new event (json)' do
      post events_url,
           params: { event: valid_attributes },
           as: :json,
           headers: { 'ACCEPT' => 'application/json' }

      expect(response).to have_http_status(:created)
      expect(response.parsed_body).to include('title' => 'Concert')
    end

    it 'fails with invalid params (json)' do
      post events_url,
           params: { event: invalid_attributes },
           as: :json,
           headers: { 'ACCEPT' => 'application/json' }

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'POST /create (JSON)' do
    it 'creates a new event (json)' do
      post events_url,
           params: { event: valid_attributes },
           as: :json,
           headers: { 'ACCEPT' => 'application/json' }

      expect(response).to have_http_status(:created)
      expect(response.parsed_body).to include('title' => 'Concert')
    end

    it 'fails with invalid params (json)' do
      post events_url,
           params: { event: invalid_attributes },
           as: :json,
           headers: { 'ACCEPT' => 'application/json' }

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'PATCH /update' do
    context 'with valid parameters' do
      it 'updates the requested event' do
        event = Event.create! valid_attributes
        patch event_url(event), params: { event: new_attributes }
        event.reload
        expect(event.title).to eq('Updated Concert')
        expect(event.location).to eq('New York')
        expect(event.starts_at.to_i).to eq(new_attributes[:starts_at].to_i)
      end

      it 'redirects to the event' do
        event = Event.create! valid_attributes
        patch event_url(event), params: { event: new_attributes }
        expect(response).to redirect_to(event_url(event))
      end
    end

    context 'with invalid parameters' do
      it 'renders a response with 422 status (unprocessable_entity)' do
        event = Event.create! valid_attributes
        patch event_url(event), params: { event: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'PATCH /update (JSON)' do
    it 'updates event (json)' do
      event = Event.create!(valid_attributes)
      patch event_url(event),
            params: { event: new_attributes },
            as: :json,
            headers: { 'ACCEPT' => 'application/json' }

      expect(response).to have_http_status(:ok)
      parsed = response.parsed_body
      expect(parsed['title']).to eq('Updated Concert')
    end

    it 'fails update with invalid params (json)' do
      event = Event.create!(valid_attributes)
      patch event_url(event),
            params: { event: invalid_attributes },
            as: :json,
            headers: { 'ACCEPT' => 'application/json' }

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'PATCH /update (JSON)' do
    it 'updates event (json)' do
      event = Event.create!(valid_attributes)
      patch event_url(event),
            params: { event: new_attributes },
            as: :json,
            headers: { 'ACCEPT' => 'application/json' }

      expect(response).to have_http_status(:ok)
      parsed = response.parsed_body
      expect(parsed['title']).to eq('Updated Concert')
    end

    it 'fails update with invalid params (json)' do
      event = Event.create!(valid_attributes)
      patch event_url(event),
            params: { event: invalid_attributes },
            as: :json,
            headers: { 'ACCEPT' => 'application/json' }

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'GET /event_confirm_delete' do
    it 'renders the confirmation delete page' do
      event = Event.create!(valid_attributes)
      get event_confirm_delete_event_path(event)
      expect(response).to be_successful
      expect(response.body).to include('Are you sure you want to delete this event?')
      expect(response.body).to include(event.title)
    end
  end

  describe 'DELETE /destroy' do
    it 'destroys the requested event' do
      event = Event.create! valid_attributes
      expect do
        delete event_url(event)
      end.to change(Event, :count).by(-1)
    end

    it 'redirects to the events list' do
      event = Event.create! valid_attributes
      delete event_url(event)
      expect(response).to redirect_to(events_url)
    end
  end

  describe 'DELETE /destroy (JSON)' do
    it 'deletes the event (json)' do
      event = Event.create!(valid_attributes)
      delete event_url(event),
             as: :json,
             headers: { 'ACCEPT' => 'application/json' }

      expect(response).to have_http_status(:no_content)
    end
  end

  describe 'Admin access' do
    it 'redirects non-admin users from /events/new' do
      # enable real require_admin!
      allow_any_instance_of(EventsController).to receive(:require_admin!).and_call_original

      non_admin = double('User', has_role?: false, roles: [double('Role')])
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(non_admin)

      get new_event_url
      expect(response).to redirect_to(events_path)
      follow_redirect!
      expect(response.body).to include('You must be an administrator')
    end
  end

  describe '#select_layout' do
    it "returns 'admin' when user has admin role" do
      controller = EventsController.new
      allow(controller).to receive(:current_user).and_return(double(has_role?: true, roles: [double('Role')]))
      expect(controller.send(:select_layout)).to eq('admin')
    end

    it "returns 'user' otherwise" do
      controller = EventsController.new
      allow(controller).to receive(:current_user).and_return(double(has_role?: false, roles: [double('Role')]))
      expect(controller.send(:select_layout)).to eq('user')
    end
  end

  describe 'private methods' do
    it 'permits correct parameters' do
      controller = EventsController.new
      params = ActionController::Parameters.new(event: valid_attributes)
      allow(controller).to receive(:params).and_return(params)

      permitted = controller.send(:event_params)
      expect(permitted.keys).to include('title', 'starts_at', 'location')
    end
  end
end
