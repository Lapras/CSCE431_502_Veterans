# app/models/approval.rb
class Approval < ApplicationRecord
  belongs_to :excusal_request
  belongs_to :approved_by_user, class_name: 'User'
  
  validates :decision, presence: true, inclusion: { in: %w[approved denied] }
  validates :decision_at, presence: true
  validates :excusal_request_id, uniqueness: true
  
  after_create :update_excusal_request_status
  
  scope :approved, -> { where(decision: 'approved') }
  scope :denied, -> { where(decision: 'denied') }
  
  private
  
  def update_excusal_request_status
    excusal_request.update(status: decision)
  end
end