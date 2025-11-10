# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DisciplineRecord, type: :model do
  subject { build(:discipline_record) }

  it 'is valid with valid attributes' do
    expect(subject).to be_valid
  end
  it 'is not valid without a reason' do
    subject.reason = nil
    expect(subject).not_to be_valid
  end

  it 'belongs to a user and given_by user' do
    expect(subject.user).to be_a(User)
    expect(subject.given_by).to be_a(User)
  end
end
