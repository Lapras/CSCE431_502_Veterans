FactoryBot.define do
  factory :user do
    # Basic attributes
    email { Faker::Internet.unique.email }
    full_name { Faker::Name.name }
    uid { SecureRandom.hex(8) }
    avatar_url { Faker::Avatar.image }

    trait :admin do
      after(:create) { |user| user.add_role(:admin) }
    end

    trait :member do
      after(:create) { |user| user.add_role(:member) }
    end

    trait :with_discipline_records do
      transient do
        discipline_count { 3 }
      end

      after(:create) do |user, evaluator|
        create_list(:discipline_record, evaluator.discipline_count, user: user, given_by: user)
      end
    end

    trait :with_attendances do
      transient do
        attendance_count { 3 }
      end

      after(:create) do |user, evaluator|
        create_list(:attendance, evaluator.attendance_count, user: user)
      end
    end
  end
end
