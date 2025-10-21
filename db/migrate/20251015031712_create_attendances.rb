# frozen_string_literal: true

class CreateAttendances < ActiveRecord::Migration[7.2]
  def change
    create_table :attendances do |t|
      t.references :user, null: false, foreign_key: true
      t.references :event, null: false, foreign_key: true
      t.string :status, null: false, default: 'pending'
      # Status options: pending, present, absent, excused, tardy
      t.datetime :checked_in_at
      t.text :notes

      t.timestamps
    end

    # Add unique constraint - one attendance record per user per event
    add_index :attendances, %i[user_id event_id], unique: true
  end
end
