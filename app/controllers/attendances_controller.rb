# app/controllers/attendances_controller.rb
class AttendancesController < ApplicationController
  layout :select_layout
  before_action :set_event
  before_action :set_attendance, only: [:edit, :update]
  before_action :require_admin!, except: [:check_in]

  # GET /events/:event_id/attendances
  def index
    @attendances = @event.attendances.includes(:user).order('users.full_name')
    @stats = @event.attendance_stats
  end

  # GET /events/:event_id/attendances/:id/edit
  def edit
  end

  # PATCH/PUT /events/:event_id/attendances/:id
  def update
    if @attendance.update(attendance_params)
      redirect_to event_attendances_path(@event), notice: 'Attendance was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # POST /events/:event_id/attendances/check_in
  def check_in
    @attendance = @event.attendance_for(current_user)
    
    unless @attendance
      @attendance = @event.attendances.create(user: current_user, status: 'pending')
    end

    if @attendance.check_in!
      redirect_to @event, notice: 'Successfully checked in!'
    else
      redirect_to @event, alert: 'Failed to check in.'
    end
  end

  # POST /events/:event_id/attendances/bulk_update
  def bulk_update
    success_count = 0
    params[:attendances]&.each do |id, attrs|
      attendance = @event.attendances.find(id)
      if attendance.update(status: attrs[:status])
        success_count += 1
      end
    end

    redirect_to event_attendances_path(@event), 
                notice: "Updated #{success_count} attendance record(s)."
  end

  private

  def set_event
    @event = Event.find(params[:event_id])
  end

  def set_attendance
    @attendance = @event.attendances.find(params[:id])
  end

  def attendance_params
    params.require(:attendance).permit(:status, :notes, :checked_in_at)
  end

  def require_admin!
    unless current_user&.has_role?(:admin)
      redirect_to events_path, alert: "You must be an administrator to perform this action."
    end
  end

  def select_layout
    if current_user&.has_role?(:admin)
      'admin'
    else
      'user'
    end
  end
end