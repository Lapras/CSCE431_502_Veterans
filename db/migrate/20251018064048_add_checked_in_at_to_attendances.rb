class AddCheckedInAtToAttendances < ActiveRecord::Migration[7.2]
  def change
    add_column :attendances, :checked_in_at, :datetime unless column_exists?(:attendances, :checked_in_at)
  end
end