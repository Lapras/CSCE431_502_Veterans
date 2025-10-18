# frozen_string_literal: true

class Event < ApplicationRecord
  validates :title, :starts_at, presence: true
  validate  :starts_at_cannot_be_in_the_past
  validate :starts_at_must_be_valid_datetime
  validates :location, presence: true
  has_many :excusal_requests, dependent: :destroy

  has_many :event_users, dependent: :destroy
  has_many :users, through: :event_users

  private

  def starts_at_cannot_be_in_the_past
    return if starts_at.blank?

    return unless starts_at < Time.zone.now

    errors.add(:starts_at, "can't be in the past")
  end

  def starts_at_must_be_valid_datetime
    return unless starts_at.present? && !starts_at.is_a?(ActiveSupport::TimeWithZone) && !starts_at.is_a?(Time)

    errors.add(:starts_at,
               'is not a valid datetime')
  end
end
