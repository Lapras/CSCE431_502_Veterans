# frozen_string_literal: true

module Admin
  class AttendanceReportsController < ApplicationController
    before_action :authenticate_user!
    before_action :require_admin!

    layout 'admin'

    # GET /admin/attendance_reports
    def index
      @q       = params[:q].to_s.strip
      sort     = safe_sort(params[:sort])
      dir      = %w[asc desc].include?(params[:dir]) ? params[:dir] : 'desc'

      absent_w = Attendance::POINT_VALUES['absent'].to_f
      tardy_w  = Attendance::POINT_VALUES['tardy'].to_f

      # Conditional aggregates; include users with no attendance rows
      base = User.left_joins(:attendances)
                 .select(<<~SQL.squish)
                   users.*,
                   COALESCE(SUM(CASE WHEN attendances.status = 'present' THEN 1 END), 0) AS total_presents,
                   COALESCE(SUM(CASE WHEN attendances.status = 'absent'  THEN 1 END), 0) AS total_absences,
                   COALESCE(SUM(CASE WHEN attendances.status = 'tardy'   THEN 1 END), 0) AS total_tardies,
                   COALESCE(SUM(CASE WHEN attendances.status = 'excused' THEN 1 END), 0) AS total_excused,
                   (
                     COALESCE(SUM(CASE WHEN attendances.status = 'absent' THEN 1 END), 0) * #{absent_w} +
                     COALESCE(SUM(CASE WHEN attendances.status = 'tardy'  THEN 1 END), 0) * #{tardy_w}
                   )::numeric AS weighed_total
                 SQL
                 .group('users.id')

      if @q.present?
        pattern = "%#{@q}%"
        base = base.where('users.full_name ILIKE ? OR users.email ILIKE ?', pattern, pattern)
      end

      @rows = base.order(Arel.sql("#{sort} #{dir}"))
    end

    private

    # Whitelist sortable columns (SQL aliases from the SELECT above + user fields)
    def safe_sort(param)
      allowed = {
        'name' => 'users.full_name',
        'email' => 'users.email',
        'present' => 'total_presents',
        'absent' => 'total_absences',
        'tardy' => 'total_tardies',
        'excused' => 'total_excused',
        'total' => 'weighed_total'
      }
      allowed[param.to_s] || 'weighed_total'
    end

    def require_admin!
      return if current_user&.has_role?(:admin)

      redirect_to root_path, alert: I18n.t('alerts.not_admin')
    end
  end
end
