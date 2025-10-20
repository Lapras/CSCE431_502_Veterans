# frozen_string_literal: true

class CreateRecurringApprovals < ActiveRecord::Migration[7.2]
  def change
    create_table :recurring_approvals do |t|
      t.references :recurring_excusal, null: false, foreign_key: true
      t.references :approved_by_user, null: false, foreign_key: { to_table: :users }
      t.string :decision, null: false
      t.timestamp :decision_at, null: false
      t.text :comment

      t.timestamps
    end

    add_index :recurring_approvals, %i[recurring_excusal_id decision]
  end
end
