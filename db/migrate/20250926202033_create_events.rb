class CreateEvents < ActiveRecord::Migration[7.2]
  def change
    create_table :events do |t|
      t.string :title
      t.datetime :starts_at
      t.string :location

      t.timestamps
    end
  end
end
