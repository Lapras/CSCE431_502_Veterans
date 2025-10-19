# frozen_string_literal: true

class ExcusalRequest < ApplicationRecord

  belongs_to :event
  validates :reason, presence: true
  validates :user_id, presence: true
  belongs_to :user
  belongs_to :event, optional: true
  has_one :approval, dependent: :destroy

  validates :event_id, presence: true

  scope :pending, -> { where(status: 'pending').or(where(status: nil)) }
  scope :approved, -> { where(status: 'approved') }
  scope :denied, -> { where(status: 'denied') }

  after_initialize :set_default_status, if: :new_record?

  def pending?
    status.nil? || status == 'pending'
  end

  def approved?
    status == 'approved'
  end

  def denied?
    status == 'denied'
  end

  private

  def set_default_status
    self.status ||= 'pending'
  end

  def validate_recurring_fields
    return unless recurring_days.blank? || recurring_start_time.blank? || recurring_end_time.blank?

    errors.add(:base, 'Recurring days and time range must be present for recurring excusals')
  end
end

