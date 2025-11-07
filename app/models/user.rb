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

  has_many :discipline_records, class_name: 'DisciplineRecord', dependent: :nullify

  # Scopes allows us to easily define filters for a model.
  # So this allows us to get all users that are members, or all ones
  scope :visible_to_admin, -> { joins(:roles).where.not(roles: { name: %w[requesting] }).distinct }
  scope :without_roles_or_requesting, lambda {
    where.missing(:roles)
         .or(left_outer_joins(:roles).where(roles: { name: 'requesting' }))
  }

  # === Attendance Reporting Scope ===
  scope :with_attendance_summary, lambda {
  absent_w = Attendance::POINT_VALUES['absent'].to_f
  tardy_w  = Attendance::POINT_VALUES['tardy'].to_f

  select(<<~SQL.squish)
    users.*,
    COALESCE(att.total_presents, 0) AS total_presents,
    COALESCE(att.total_absences, 0) AS total_absences,
    COALESCE(att.total_tardies, 0) AS total_tardies,
    COALESCE(att.total_excused, 0) AS total_excused,
    COALESCE(d.total_discipline_points, 0)::numeric(10,2) AS total_discipline_points,
    (
      COALESCE(att.total_absences, 0) * #{absent_w} +
      COALESCE(att.total_tardies, 0) * #{tardy_w} +
      COALESCE(d.total_discipline_points, 0)
    )::numeric(10,2) AS weighed_total
  SQL
    .joins(<<~SQL.squish)
      LEFT JOIN (
        SELECT user_id,
               SUM(CASE WHEN status = 'present' THEN 1 ELSE 0 END) AS total_presents,
               SUM(CASE WHEN status = 'absent' THEN 1 ELSE 0 END) AS total_absences,
               SUM(CASE WHEN status = 'tardy' THEN 1 ELSE 0 END) AS total_tardies,
               SUM(CASE WHEN status = 'excused' THEN 1 ELSE 0 END) AS total_excused
        FROM attendances
        GROUP BY user_id
      ) att ON att.user_id = users.id
    SQL
    .joins(<<~SQL.squish)
      LEFT JOIN (
        SELECT user_id,
                 SUM(
                   CASE
                     WHEN record_type = 'absence' THEN 1
                     WHEN record_type = 'tardy'   THEN 1.0 / 3.0
                     ELSE 0
                   END
                 )
                AS total_discipline_points
        FROM discipline_records
        GROUP BY user_id
      ) d ON d.user_id = users.id
    SQL
}

  # Optional: allow searching
  scope :search, lambda { |query|
    return all if query.blank?

    pattern = "%#{query.strip}%"
    where('users.full_name ILIKE ? OR users.email ILIKE ?', pattern, pattern)
  }

  # Optional: safe sorting (can live here or stay in controller)
  def self.safe_sort(column, direction)
    allowed = {
      'name' => 'users.full_name',
      'email' => 'users.email',
      'present' => 'total_presents',
      'absent' => 'total_absences',
      'tardy' => 'total_tardies',
      'excused' => 'total_excused',
      'discipline' => 'total_discipline_points',
      'total' => 'weighed_total'
    }
    col = allowed[column.to_s] || 'weighed_total'
    dir = %w[asc desc].include?(direction.to_s.downcase) ? direction.to_s.downcase : 'desc'
    order("#{col} #{dir}")
  end

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

  # Compute total "discipline points" based on enum record_type
  # tardy = 0.33, absence = 1.0, and every 3 tardies round up to 1 absence
  def total_discipline_points
    tardies  = discipline_records.tardy.count
    absences = discipline_records.absence.count

    # Convert every 3 tardies into 1 absence equivalent
    absences + (tardies * 0.33)
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
      discipline: total_discipline_points.round(2),
      points: total_attendance_points.round(2)
    }
  end
end
