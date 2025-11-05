FactoryBot.define do
  factory :discipline_record do
    association :user
    association :given_by, factory: :user

    points { Faker::Number.between(from: 0.3, to: 2) }
    reason { Faker::Lorem.sentence(word_count: 5) }
  end
end
