class ExcusalRequest < ApplicationRecord
  belongs_to :user
  belongs_to :event, optional: true   
  serialize :recurring_days, Array   
  validates :reason, presence: true
  validates :user_id, presence: true
  validates :event_id, presence: true, unless: -> { recurring }
  validate :validate_recurring_fields, if: -> { recurring }
  private
  def validate_recurring_fields
    if recurring_days.blank? || recurring_start_time.blank? || recurring_end_time.blank?
      errors.add(:base, "Recurring days and time range must be present for recurring excusals")
    end
  end
end