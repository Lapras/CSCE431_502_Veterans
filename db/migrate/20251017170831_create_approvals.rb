class CreateApprovals < ActiveRecord::Migration[7.2]
  def change
    create_table :approvals do |t|
      t.references :excusal_request, null: false, foreign_key: true
      t.references :approved_by_user, null: false, foreign_key: { to_table: :users }
      t.string :decision, null: false # 'approved' or 'denied'
      t.timestamp :decision_at, null: false
      t.text :comment

      t.timestamps
    end
    
    # Add index for faster queries
    add_index :approvals, [:excusal_request_id, :decision]
  end
end