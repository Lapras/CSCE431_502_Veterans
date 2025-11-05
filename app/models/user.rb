# frozen_string_literal: true

class User < ApplicationRecord
  rolify

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :omniauthable, omniauth_providers: [:google_oauth2]

  validates :email, presence: true, uniqueness: true

  # Attendance related associations
  has_many :attendances, dependent: :destroy
  has_many :attended_events, through: :attendances, source: :event

  # Event assignment (which events this user is assigned to)
  has_many :event_users, dependent: :destroy
  has_many :assigned_events, through: :event_users, source: :event

  # Excusal related associations
  has_many :excusal_requests, dependent: :destroy
  has_many :recurring_excusals, dependent: :destroy

  has_many :discipline_records, class_name: 'DisciplineRecord', foreign_key: 'given_by_id', dependent: :nullify

  # Backwards compatibility alias
  def events
    assigned_events
  end

  def self.from_google(email:, full_name:, uid:, avatar_url:)
    create_with(uid: uid, full_name: full_name, avatar_url: avatar_url).find_or_create_by!(email: email)
  end

  def set_roles!(names)
    names = Array(names).map(&:to_s).compact_blank
    (roles.pluck(:name) - names).each { |r| remove_role(r) }
    (names - roles.pluck(:name)).each { |r| add_role(r) }
  end

  # approvals
  has_many :approvals,
           foreign_key: :approved_by_user_id,
           inverse_of: :approved_by_user,
           dependent: :destroy

  has_many :recurring_approvals,
           foreign_key: :approved_by_user_id,
           inverse_of: :approved_by_user,
           dependent: :destroy

  # attendance related methods
  def attendance_for(event)
    attendances.find_by(event: event)
  end

  def total_attendance_points
    attendances.sum(&:point_value)
  end

  def attendance_stats
    {
      total_events: attendances.count,
      present: attendances.present.count,
      absent: attendances.absent.count,
      excused: attendances.excused.count,
      tardy: attendances.tardy.count,
      points: total_attendance_points
    }
  end
end
