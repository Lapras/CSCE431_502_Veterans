module Admin::AttendanceReportsHelper
  def sort_link(label, key)
    current_sort = params[:sort].to_s
    current_dir  = params[:dir].to_s
    next_dir     = (current_sort == key.to_s && current_dir == 'desc') ? 'asc' : 'desc'

    link_to label, admin_attendance_reports_path(
      q: params[:q],
      sort: key,
      dir: next_dir
    )
  end
end
