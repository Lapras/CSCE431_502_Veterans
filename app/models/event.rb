# frozen_string_literal: true

# app/models/event.rb
class Event < ApplicationRecord
  # Attendance tracking (for actual attendance records)
  has_many :attendances, dependent: :destroy
  has_many :attended_by_users, through: :attendances, source: :user

  # Event assignment (which users are assigned to this event)
  has_many :event_users, dependent: :destroy
  has_many :assigned_users, through: :event_users, source: :user
  has_many :event_users, dependent: :destroy
  has_many :users, through: :event_users

  validates :title, :starts_at, presence: true
  validate  :starts_at_cannot_be_in_the_past
  validate :starts_at_must_be_valid_datetime
  validates :location, presence: true

  has_many :excusal_requests, dependent: :destroy

  # Create attendance records for assigned users when event is created
  after_create :create_attendance_records

  # Get attendance for a specific user
  def attendance_for(user)
    return nil unless user

    attendances.find_by(user_id: user.id)
  end

  # Check if user has checked in
  def user_checked_in?(user)
    attendance = attendance_for(user)
    %w[present tardy].include?(attendance&.status)
  end

  # Attendance statistics (only count assigned users)
  def attendance_stats
    {
      total: attendances.count,
      present: attendances.present.count,
      absent: attendances.absent.count,
      excused: attendances.excused.count,
      tardy: attendances.tardy.count,
      pending: attendances.pending.count
    }
  end

  # Backwards compatibility alias
  def users
    assigned_users
  end

  private

  def starts_at_cannot_be_in_the_past
    return if starts_at.blank? # let presence validator handle blank

    # If not a time-like object, add a clear error and stop.
    unless starts_at.is_a?(Time) || starts_at.is_a?(ActiveSupport::TimeWithZone)
      errors.add(:starts_at, 'is not a valid datetime')
      return
    end

    return unless starts_at < Time.zone.now

    errors.add(:starts_at, "can't be in the past")
  end

  def starts_at_must_be_valid_datetime
    return unless starts_at.present? && !starts_at.is_a?(ActiveSupport::TimeWithZone) && !starts_at.is_a?(Time)

    errors.add(:starts_at,
               'is not a valid datetime')
  end

  def create_attendance_records
    # Only create attendance records for assigned users
    assigned_users.each do |user|
      attendances.find_or_create_by(user: user) do |attendance|
        attendance.status = 'pending'
      end
    end
  end
end
