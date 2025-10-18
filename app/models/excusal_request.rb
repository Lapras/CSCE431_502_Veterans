class ExcusalRequest < ApplicationRecord
  belongs_to :user
  belongs_to :event
  has_one :approval, dependent: :destroy 
  
  validates :reason, presence: true
  validates :user_id, presence: true
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
end