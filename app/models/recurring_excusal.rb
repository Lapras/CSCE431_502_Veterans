class RecurringExcusal < ApplicationRecord
  belongs_to :user
  serialize :recurring_days, coder: JSON
  validates :reason, presence: true
  validates :recurring_days, presence: true
  validates :recurring_start_time, presence: true
  validates :recurring_end_time, presence: true
  validates :status, inclusion: { in: %w[pending approved denied] }
  scope :approved, -> { where(status: 'approved') }
end
