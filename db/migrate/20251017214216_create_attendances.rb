class CreateAttendances < ActiveRecord::Migration[7.2]
  def change
    create_table :attendances do |t|
      t.references :event, null: false, foreign_key: true
      t.references :user,  null: false, foreign_key: true
      t.string :status,    null: false, default: 'unknown'

      t.timestamps
    end

    add_index :attendances, [:event_id, :user_id], unique: true
  end
end
