# frozen_string_literal: true

class CreateRecurringExcusals < ActiveRecord::Migration[7.2]
  def change
    create_table :recurring_excusals do |t|
      t.references :user, null: false, foreign_key: true
      t.string :recurring_days
      t.time :recurring_start_time
      t.time :recurring_end_time
      t.text :reason
      t.string :status

      t.timestamps
    end
  end
end
