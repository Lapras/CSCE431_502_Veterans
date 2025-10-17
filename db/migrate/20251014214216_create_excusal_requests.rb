class CreateExcusalRequests < ActiveRecord::Migration[7.2]
  def change
    create_table :excusal_requests do |t|
      t.references :user, null: false, foreign_key: true
      t.references :event, null: false, foreign_key: true
      t.text :reason
      t.string :status

      t.timestamps
    end
  end
end
