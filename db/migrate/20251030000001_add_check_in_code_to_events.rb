# frozen_string_literal: true

class AddCheckInCodeToEvents < ActiveRecord::Migration[7.2]
  def up
    add_column :events, :check_in_code, :string

    # Generate codes for existing events
    # rubocop:disable Rails/SkipsModelValidations
    Event.find_each do |event|
      event.update_column(:check_in_code, format('%03d', rand(0..999)))
    end
    # rubocop:enable Rails/SkipsModelValidations
  end

  def down
    remove_column :events, :check_in_code
  end
end
