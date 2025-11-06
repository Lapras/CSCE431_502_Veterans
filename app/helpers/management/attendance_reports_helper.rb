# frozen_string_literal: true

module Management
  module AttendanceReportsHelper
    TITLES = {
      'name' => 'Name',
      'email' => 'Email',
      'total' => 'Total',
      'present' => 'Present',
      'absent' => 'Absent',
      'tardy' => 'Tardy',
      'excused' => 'Excused'
    }.freeze

    # shared state
    def current_sort
      params[:sort].to_s
    end

    def current_dir
      d = params[:dir].to_s.downcase
      %w[asc desc].include?(d) ? d : 'desc'
    end

    # toolbar display
    def current_sort_key
      key = current_sort
      %w[name email total present absent tardy excused].include?(key) ? key : 'total'
    end

    def current_sort_dir
      current_dir
    end

    def current_sort_title
      TITLES[current_sort_key]
    end

    def current_sort_arrow
      current_sort_dir == 'asc' ? '↑' : '↓'
    end

    # header links (no arrows here)
    def next_dir(column)
      if current_sort == column.to_s
        current_dir == 'asc' ? 'desc' : 'asc'
      else
        'desc'
      end
    end

    def sort_link(label, key)
      link_to(
        label,
        management_attendance_reports_path(q: params[:q], sort: key, dir: next_dir(key)),
        class: "sort-button #{'active' if current_sort == key.to_s}"
      )
    end
  end
end
