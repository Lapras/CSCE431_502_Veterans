# frozen_string_literal: true

FactoryBot.define do
  factory :discipline_record do
    association :user
    association :given_by, factory: :user

    record_type { DisciplineRecord.record_types.keys.sample } # "tardy" or "absence"
    reason { Faker::Lorem.sentence(word_count: 5) }
  end
end
