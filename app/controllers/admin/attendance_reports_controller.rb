# frozen_string_literal: true

module Admin
  class AttendanceReportsController < BaseController
    # GET /admin/attendance_reports
    def index
      @q = params[:q].to_s.strip
      @rows = build_base_query
      @rows = filter_by_query(@rows, @q) if @q.present?
      @rows = @rows.order(sort_column => sort_dir)
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

    # Whitelist sort direction
    def safe_direction(param)
      %w[asc desc].include?(param.to_s.downcase) ? param.to_s.downcase : 'desc'
    end

    def require_admin!
      return if current_user&.has_role?(:admin)

      redirect_to root_path, alert: I18n.t('alerts.not_admin')
    end

    def build_base_query
      absent_w = Attendance::POINT_VALUES['absent'].to_f
      tardy_w  = Attendance::POINT_VALUES['tardy'].to_f

      User.left_joins(:attendances)
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
    end

    def filter_by_query(base, query)
      pattern = "%#{query}%"
      base.where('users.full_name ILIKE ? OR users.email ILIKE ?', pattern, pattern)
    end

    def sort_column
      allowed = {
        'name' => 'users.full_name',
        'email' => 'users.email',
        'present' => 'total_presents',
        'absent' => 'total_absences',
        'tardy' => 'total_tardies',
        'excused' => 'total_excused',
        'total' => 'weighed_total'
      }
      allowed[params[:sort].to_s] || 'weighed_total'
    end

    def sort_dir
      %w[asc desc].include?(params[:dir].to_s.downcase) ? params[:dir].to_s.downcase : 'desc'
    end
  end
end
