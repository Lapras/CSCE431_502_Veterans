# frozen_string_literal: true

class EventsController < ApplicationController
  layout :select_layout
  before_action :set_event, only: %i[show edit update destroy event_confirm_delete]
  before_action :require_admin!, except: %i[index show]

  # GET /events or /events.json
  def index
    @events = if current_user&.has_role?(:admin)
                # Admins see all future events
                Event.where(starts_at: Time.current..).order(:starts_at)
              else
                # Regular users only see events they're assigned to
                current_user.events.where(starts_at: Time.current..).order(:starts_at)
              end
  end

  # GET /events/1 or /events/1.json
  def show
    # Check if user is authorized to view this event
    unless current_user&.has_role?(:admin) || @event.assigned_users.include?(current_user)
      redirect_to events_path, alert: I18n.t('alerts.not_authorized')
      return
    end

    # Ensure attendance records exist for assigned users
    # This is already handled by the Event model's after_create callback
    # but we ensure they exist for events that were created before the callback
    @event.assigned_users.each do |u|
      @event.attendances.find_or_create_by(user: u) do |attendance|
        attendance.status = 'pending'
      end
    end
  end

  # GET /events/new
  def new
    @event = Event.new
  end

  # GET /events/1/edit
  def edit; end

  # POST /events or /events.json
  def create
    @event = Event.new(event_params.except(:user_ids))

    respond_to do |format|
      if @event.save
        assign_users_to_event
        format.html { redirect_to @event, notice: I18n.t('event.created') }
        format.json { render :show, status: :created, location: @event }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /events/1 or /events/1.json
  def update
    respond_to do |format|
      if @event.update(event_params.except(:user_ids))
        assign_users_to_event
        format.html { redirect_to @event, notice: I18n.t('event.updated'), status: :see_other }
        format.json { render :show, status: :ok, location: @event }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /events/1 or /events/1.json
  def destroy
    @event.destroy!

    respond_to do |format|
      format.html { redirect_to events_path, notice: I18n.t('event.deleted'), status: :see_other }
      format.json { head :no_content }
    end
  end

  def event_confirm_delete
    @event = Event.find(params[:id])
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_event
    @event = Event.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def event_params
    params.require(:event).permit(:title, :starts_at, :location, :notes, user_ids: [])
  end

  def require_admin!
    return if current_user&.has_role?(:admin)

    redirect_to events_path, alert: I18n.t('alerts.not_admin')
  end

  def select_layout
    if current_user&.has_role?(:admin)
      'admin'
    else
      'user'
    end
  end

  def assign_users_to_event
    return if params[:event][:user_ids].blank?

    @event.assigned_users = User.where(id: params[:event][:user_ids])
    # Create attendance records for newly assigned users
    @event.assigned_users.each do |user|
      @event.attendances.find_or_create_by(user: user) do |attendance|
        attendance.status = 'pending'
      end
    end
  end
end
