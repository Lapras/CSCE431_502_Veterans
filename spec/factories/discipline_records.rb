FactoryBot.define do
  factory :discipline_record do
    association :user
    association :given_by, factory: :user
    points { rand(1..10) }
    reason { 'Test reason' }
  end
end
