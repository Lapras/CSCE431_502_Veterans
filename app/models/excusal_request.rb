# frozen_string_literal: true

class ExcusalRequest < ApplicationRecord
  belongs_to :user
  belongs_to :event
  validates :reason, presence: true
end
