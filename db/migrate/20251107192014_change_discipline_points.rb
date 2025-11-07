class ChangeDisciplinePoints < ActiveRecord::Migration[7.0]
  def up
    rename_column :discipline_records, :points, :record_type
    change_column :discipline_records, :record_type, :string, default: 'tardy', null: false
  end

  def down
    change_column :discipline_records, :record_type, 'integer USING (record_type::numeric::integer)'
    rename_column :discipline_records, :record_type, :points
  end
end
