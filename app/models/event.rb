# app/models/event.rb
class Event < ApplicationRecord
  has_many :attendances, dependent: :destroy
  has_many :users, through: :attendances

  validates :title, :starts_at, presence: true
  validate  :starts_at_cannot_be_in_the_past
  validate :starts_at_must_be_valid_datetime
  validates :location, presence: true

  # Create attendance records for all members when event is created
  after_create :create_attendance_records

  # Get attendance for a specific user
  def attendance_for(user)
    attendances.find_by(user: user)
  end

  # Check if user has checked in
  def user_checked_in?(user)
    attendance = attendance_for(user)
    attendance&.status == 'present' || attendance&.status == 'tardy'
  end

  # Attendance statistics
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

  private

  def starts_at_cannot_be_in_the_past
    return if starts_at.blank?
    if starts_at < Time.zone.now
      errors.add(:starts_at, "can't be in the past")
    end
  end
  
  def starts_at_must_be_valid_datetime
    errors.add(:starts_at, "is not a valid datetime") if starts_at.present? && !starts_at.is_a?(ActiveSupport::TimeWithZone) && !starts_at.is_a?(Time)
  end

  def create_attendance_records
    User.with_role(:member).find_each do |user|
      attendances.create(user: user, status: 'pending')
    end
  end
end