# frozen_string_literal: true

class ExcusalRequest < ApplicationRecord
  belongs_to :user
  belongs_to :event
  has_one :approval, dependent: :destroy

  validates :reason, presence: true

  scope :pending, -> { where(status: 'pending').or(where(status: nil)) }
  scope :approved, -> { where(status: 'approved') }
  scope :denied, -> { where(status: 'denied') }

  validates :evidence_link, format: URI::DEFAULT_PARSER.make_regexp(%w[http https]), allow_blank: true

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
