module Admin
  module AttendanceReportsHelper
    TITLES = {
      "name"    => "Name",
      "email"   => "Email",
      "total"   => "Total",
      "present" => "Present",
      "absent"  => "Absent",
      "tardy"   => "Tardy",
      "excused" => "Excused"
    }.freeze

    def current_sort_key
      key = params[:sort].to_s
      %w[name email total present absent tardy excused].include?(key) ? key : "total"
    end

    def current_sort_dir
      dir = params[:dir].to_s.downcase
      %w[asc desc].include?(dir) ? dir : "desc"
    end

    def current_sort_title
      TITLES[current_sort_key]
    end

    def current_sort_arrow
      current_sort_dir == "asc" ? "↑" : "↓"
    end

    def next_dir(column)
      if current_sort == column.to_s && current_dir == "asc"
        "desc"
      else
        "asc"
      end
    end

    def sort_link(label, key)
      link_to(
        label,
        admin_attendance_reports_path(q: params[:q], sort: key, dir: next_dir(key)),
        class: "sort-button #{'active' if current_sort == key.to_s}"
      )
    end

    def current_sort
      params[:sort].to_s
    end

    def current_dir
      params[:dir].to_s.downcase
    end
  end
end