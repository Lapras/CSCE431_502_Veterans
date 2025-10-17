class ExcusalRequest < ApplicationRecord
  belongs_to :user
  belongs_to :event
  validates :reason, presence: true
  validates :user_id, presence: true
  validates :event_id, presence: true
end
