module Admin
  class AttendanceReportsController < ApplicationController
    before_action :authenticate_user!
    before_action :require_admin!

    # GET /admin/attendance_reports
    def index
      @q       = params[:q].to_s.strip
      sort     = safe_sort(params[:sort])
      dir      = %w[asc desc].include?(params[:dir]) ? params[:dir] : 'desc'

      # Conditional aggregates; include users with no attendance rows
      base = User.left_joins(:attendances)
                 .select(<<~SQL)
                   users.*,
                   COUNT(attendances.id)                                            AS total_attendances,
                   COALESCE(SUM(CASE WHEN attendances.status = 'present' THEN 1 END), 0) AS total_presents,
                   COALESCE(SUM(CASE WHEN attendances.status = 'absent'  THEN 1 END), 0) AS total_absences,
                   COALESCE(SUM(CASE WHEN attendances.status = 'tardy'   THEN 1 END), 0) AS total_tardies,
                   COALESCE(SUM(CASE WHEN attendances.status = 'excused' THEN 1 END), 0) AS total_excused
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
        'name'           => 'users.full_name',
        'email'          => 'users.email',
        'total'          => 'total_attendances',
        'present'        => 'total_presents',
        'absent'         => 'total_absences',
        'tardy'          => 'total_tardies',
        'excused'        => 'total_excused'
      }
      allowed[param.to_s] || 'total_absences'
    end

    def require_admin!
      return if current_user&.has_role?(:admin)
      redirect_to root_path, alert: I18n.t('alerts.not_admin')
    end
  end
end