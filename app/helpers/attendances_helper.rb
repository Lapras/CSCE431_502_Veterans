# frozen_string_literal: true

# app/helpers/attendances_helper.rb
module AttendancesHelper
  def status_badge_class(status)
    case status
    when 'present'
      'badge-success'
    when 'absent'
      'badge-danger'
    when 'excused'
      'badge-info'
    when 'tardy'
      'badge-warning'
    else
      'badge-secondary'
    end
  end

  def attendance_percentage(event)
    stats = event.attendance_stats
    return 0 if stats[:total].zero?

    ((stats[:present].to_f / stats[:total]) * 100).round(1)
  end
end
