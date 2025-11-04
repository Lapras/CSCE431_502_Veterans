# frozen_string_literal: true

module Admin
  class AttendanceReportsController < ApplicationController
    before_action :authenticate_user!
    before_action :require_admin!

    layout 'admin'

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
        'discipline' => 'total_discipline_points',
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
      tardy_w = Attendance::POINT_VALUES['tardy'].to_f

      User
        .select(<<~SQL.squish)
          users.*,
          COALESCE(att.total_presents, 0) AS total_presents,
          COALESCE(att.total_absences, 0) AS total_absences,
          COALESCE(att.total_tardies, 0) AS total_tardies,
          COALESCE(att.total_excused, 0) AS total_excused,
          COALESCE(d.total_discipline_points, 0) AS total_discipline_points,
          (
            COALESCE(att.total_absences, 0) * #{absent_w} +
            COALESCE(att.total_tardies, 0) * #{tardy_w} +
            COALESCE(d.total_discipline_points, 0)
          )::numeric AS weighed_total
        SQL
        .joins(<<~SQL.squish)
          LEFT JOIN (
            SELECT user_id,
                   SUM(CASE WHEN status = 'present' THEN 1 ELSE 0 END) AS total_presents,
                   SUM(CASE WHEN status = 'absent' THEN 1 ELSE 0 END) AS total_absences,
                   SUM(CASE WHEN status = 'tardy' THEN 1 ELSE 0 END) AS total_tardies,
                   SUM(CASE WHEN status = 'excused' THEN 1 ELSE 0 END) AS total_excused
            FROM attendances
            GROUP BY user_id
          ) att ON att.user_id = users.id
        SQL
        .joins(<<~SQL.squish)
          LEFT JOIN (
            SELECT user_id,
                   COALESCE(SUM(points),0) AS total_discipline_points
            FROM discipline_records
            GROUP BY user_id
          ) d ON d.user_id = users.id
        SQL
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
        'discipline' => 'total_discipline_points',
        'total' => 'weighed_total'
      }
      allowed[params[:sort].to_s] || 'weighed_total'
    end

    def sort_dir
      %w[asc desc].include?(params[:dir].to_s.downcase) ? params[:dir].to_s.downcase : 'desc'
    end
  end
end
