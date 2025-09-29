class Event < ApplicationRecord
  validates :title, :starts_at, presence: true
  validate  :starts_at_cannot_be_in_the_past
  validate :starts_at_must_be_valid_datetime
  validates :location, presence: true



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
end
