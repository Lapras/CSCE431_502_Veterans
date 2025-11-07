# frozen_string_literal: true

class DisciplineRecord < ApplicationRecord
  belongs_to :user
  belongs_to :given_by, class_name: 'User'

  enum :record_type, { tardy: 'tardy', absence: 'absence' }, suffix: true
  validates :reason, presence: true
end
