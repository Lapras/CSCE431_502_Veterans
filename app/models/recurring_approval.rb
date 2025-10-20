# frozen_string_literal: true

class RecurringApproval < ApplicationRecord
  belongs_to :recurring_excusal
  belongs_to :approved_by_user, class_name: 'User'

  validates :decision, presence: true, inclusion: { in: %w[approved denied] }
  validates :decision_at, presence: true
  validates :recurring_excusal_id, uniqueness: true

  after_create :update_recurring_excusal_status

  scope :approved, -> { where(decision: 'approved') }
  scope :denied, -> { where(decision: 'denied') }

  private

  def update_recurring_excusal_status
    recurring_excusal.update(status: decision)
  end
end
