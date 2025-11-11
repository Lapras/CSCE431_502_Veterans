# frozen_string_literal: true

module Admin
  class AttendanceReportsController < BaseController
    # GET /admin/attendance_reports
    skip_load_and_authorize_resource

    def index
      set_query_params
      set_events
      load_rows
      compute_summary
    end

    def require_admin!
      redirect_to root_path, alert: t('admin.users.unauthorized') unless current_user&.has_role?(:admin)
    end

    private

    def set_query_params
      @q = params[:q].to_s.strip
      @last_n = params[:last_n].present? ? params[:last_n].to_i : nil
    end

    def set_events
      events_scope = Event.order(starts_at: :desc)
      events_scope = events_scope.limit(@last_n) if @last_n.present?
      @event_ids = events_scope.pluck(:id)
    end

    def load_rows
      @rows = User
              .with_attendance_summary(@event_ids)
              .search(@q)
              .safe_sort(params[:sort], params[:dir])
    end

    def compute_summary
      @summary_stats = Attendance.where(event_id: @event_ids)
                                 .group(:status)
                                 .count
      total = @summary_stats.values.sum.to_f
      @summary_percentages = if total.positive?
                               @summary_stats.transform_values { |v| ((v / total) * 100).round(1) }
                             else
                               {}
                             end
    end
  end
end
