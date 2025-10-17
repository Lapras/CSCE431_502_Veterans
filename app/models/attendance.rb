class Attendance < ApplicationRecord
  belongs_to :event
  belongs_to :user

  enum status: {
    unknown: 'unknown',
    present: 'present',
    absent:  'absent',
    tardy: 'tardy',
    excused: 'excused'
  }

  validates :user_id, uniqueness: { scope: :event_id }
end
