# frozen_string_literal: true

# app/controllers/attendances_controller.rb
class AttendancesController < ApplicationController
  layout :select_layout
  before_action :set_event
  before_action :set_attendance, only: %i[edit update]
  before_action :require_admin_or_officer!, except: [:check_in]

  # GET /events/:event_id/attendances
  def index
    @attendances = filtered_attendances
    @stats = @event.attendance_stats
  end

  # GET /events/:event_id/attendances/:id/edit
  def edit; end

  # PATCH/PUT /events/:event_id/attendances/:id
  def update
    if @attendance.update(attendance_params)
      redirect_to event_attendances_path(@event), notice: I18n.t('attendance.updated')
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # POST /events/:event_id/attendances/check_in
  def check_in
    @attendance = @event.attendance_for(current_user)

    @attendance ||= @event.attendances.create(user: current_user, status: 'pending')

    # Validate check-in code
    unless @event.valid_check_in_code?(params[:check_in_code])
      redirect_to @event, alert: I18n.t('attendance.invalid_code')
      return
    end

    if @attendance.check_in!
      redirect_to @event, notice: I18n.t('attendance.checkin')
    else
      redirect_to @event, alert: I18n.t('attendance.checkin_fail')
    end
  end

  # POST /events/:event_id/attendances/bulk_update
  def bulk_update
    success_count = 0
    params[:attendances]&.each do |id, attrs|
      attendance = @event.attendances.find(id)
      # Only update if status has changed
      success_count += 1 if (attendance.status != attrs[:status]) && attendance.update(status: attrs[:status])
    end

    redirect_to event_attendances_path(@event),
                notice: "Updated #{success_count} attendance record(s)."
  end

  def filtered_attendances
    scope = base_scope
    scope = filter_status(scope)
    scope = filter_search(scope)
    scope.order('users.full_name')
  end

  private

  def base_scope
    @event.attendances.includes(:user)
  end

  def filter_status(scope)
    return scope if params[:status_filter].blank?

    scope.where(status: params[:status_filter])
  end

  def filter_search(scope)
    return scope if params[:search].blank?

    scope.joins(:user).merge(User.search(params[:search]))
  end

  def set_event
    @event = Event.find(params[:event_id])
  end

  def set_attendance
    @attendance = @event.attendances.find(params[:id])
  end

  def attendance_params
    params.require(:attendance).permit(:status, :notes, :checked_in_at)
  end

  def require_admin_or_officer!
    return if current_user&.has_role?(:admin) || current_user&.has_role?(:officer)

    redirect_to events_path, alert: I18n.t('admin.users.unauthorized')
  end

  def select_layout
    if current_user&.has_role?(:admin) || current_user&.has_role?(:officer)
      'admin'
    else
      'user'
    end
  end
end
