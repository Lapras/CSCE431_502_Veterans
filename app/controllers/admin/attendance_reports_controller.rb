# frozen_string_literal: true

module Admin
  class AttendanceReportsController < ApplicationController
    before_action :authenticate_user!
    before_action :require_admin!

    layout 'admin'

    # GET /admin/attendance_reports
    def index
      @q = params[:q].to_s.strip
      @rows = User
              .with_attendance_summary
              .search(@q)
              .safe_sort(params[:sort], params[:dir])
    end

    def require_admin!
      redirect_to root_path, alert: t('admin.users.unauthorized') unless current_user&.has_role?(:admin)
    end
  end
end
