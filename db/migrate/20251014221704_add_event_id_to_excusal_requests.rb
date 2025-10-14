class AddEventIdToExcusalRequests < ActiveRecord::Migration[7.2]
  def change
    add_reference :excusal_requests, :event, null: false, foreign_key: true
  end
end
