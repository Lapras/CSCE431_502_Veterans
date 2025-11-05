# frozen_string_literal: true

class RecurringExcusal < ApplicationRecord
  belongs_to :user
  serialize :recurring_days, coder: JSON
  validates :reason, presence: true
  validates :recurring_days, presence: true
  validates :recurring_start_time, presence: true
  validates :recurring_end_time, presence: true
  validates :status, inclusion: { in: %w[pending approved denied] }

  validates :evidence_link, format: URI::DEFAULT_PARSER.make_regexp(%w[http https]), allow_blank: true

  scope :approved, -> { where(status: 'approved') }

  has_one :recurring_approval, dependent: :destroy

  scope :pending, -> { where(status: 'pending').or(where(status: nil)) }
  scope :denied, -> { where(status: 'denied') }
end
