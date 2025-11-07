# frozen_string_literal: true

class DisciplineRecord < ApplicationRecord
  belongs_to :user
  belongs_to :given_by, class_name: 'User'

  validates :points, presence: true, numericality: true
  validates :reason, presence: true
end
