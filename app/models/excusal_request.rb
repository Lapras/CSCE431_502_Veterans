# class ExcusalRequest < ApplicationRecord
#   belongs_to :user
#   belongs_to :event
#   validates :reason, presence: true
#   validates :user_id, presence: true
#   validates :event_id, presence: true
# end

class ExcusalRequest < ApplicationRecord
  belongs_to :user
  belongs_to :event
  has_one :approval, dependent: :destroy  # ADD THIS LINE
  
  validates :reason, presence: true
  validates :user_id, presence: true
  validates :event_id, presence: true
  
  # ADD THESE SCOPES
  scope :pending, -> { where(status: 'pending').or(where(status: nil)) }
  scope :approved, -> { where(status: 'approved') }
  scope :denied, -> { where(status: 'denied') }
  
  # ADD THIS CALLBACK
  after_initialize :set_default_status, if: :new_record?
  
  # ADD THESE METHODS
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