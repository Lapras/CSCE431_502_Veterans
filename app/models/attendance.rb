# frozen_string_literal: true

# app/models/attendance.rb
class Attendance < ApplicationRecord
  belongs_to :user
  belongs_to :event

  enum :status, {
    pending: 'pending',
    present: 'present',
    absent: 'absent',
    tardy: 'tardy',
    excused: 'excused'
  }

  # Status values for dropdowns (key => label)
  STATUSES = {
    'pending' => 'Pending',
    'present' => 'Present',
    'absent' => 'Absent',
    'excused' => 'Excused',
    'tardy' => 'Tardy'
  }.freeze

  # Point values for each status
  POINT_VALUES = {
    'present' => 0,
    'excused' => 0,
    'tardy' => 0.33,
    'absent' => 1,
    'pending' => 0
  }.freeze

  validates :user_id, uniqueness: { scope: :event_id, message: I18n.t('attendance.already') }

  # Scopes
  scope :for_event, ->(event) { where(event: event) }
  scope :for_user, ->(user) { where(user: user) }

  # Check in a user
  def check_in!
    update!(status: 'present', checked_in_at: Time.current)
  end

  # Mark as tardy
  def mark_tardy!
    update!(status: 'tardy', checked_in_at: Time.current)
  end

  # Get point value for this attendance
  def point_value
    POINT_VALUES[status] || 0
  end

  # Human readable status
  def status_label
    STATUSES[status] || status.humanize
  end
end
