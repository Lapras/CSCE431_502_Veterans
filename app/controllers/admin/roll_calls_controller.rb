# app/controllers/admin/roll_calls_controller.rb
module Admin
  class RollCallsController < ApplicationController
    before_action :require_admin!

    # PATCH /admin/events/:event_id/roll_call
    def update
      event   = Event.find(params[:event_id])
      updates = attendances_params # => { "3" => {"status"=>"present"}, ... }

      Attendance.transaction do
        updates.each do |attendance_id, attrs|
          status = attrs["status"] || attrs[:status]
          Attendance.where(id: attendance_id, event_id: event.id)
                    .update_all(status: status)
        end
      end

      redirect_to event_path(event), notice: "Roll call progress saved."
    rescue ActionController::ParameterMissing
      redirect_to event_path(event), alert: "Nothing to save."
    end

    private

    def attendances_params
      # params[:attendances] is a hash-of-hashes coming from radio buttons
      # Convert it to a plain Hash (string keys are fine).
      params.require(:attendances).to_unsafe_h
      # or, if you prefer the safer route:
      # params.require(:attendances).permit!.to_h
    end

    def require_admin!
      return if current_user&.has_role?(:admin)
      redirect_to events_path, alert: I18n.t("alerts.not_admin")
    end
  end
end