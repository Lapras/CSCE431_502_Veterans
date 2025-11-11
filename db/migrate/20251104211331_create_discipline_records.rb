# frozen_string_literal: true

class CreateDisciplineRecords < ActiveRecord::Migration[7.2]
  def change
    create_table :discipline_records do |t|
      t.references :user, null: false, foreign_key: true
      t.references :given_by, null: false, foreign_key: { to_table: :users }
      t.decimal :points, precision: 8, scale: 2, null: false, default: 0
      t.text :reason, null: false

      t.timestamps
    end
  end
end
