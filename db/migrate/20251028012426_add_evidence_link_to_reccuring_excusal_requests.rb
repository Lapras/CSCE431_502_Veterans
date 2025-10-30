class AddEvidenceLinkToReccuringExcusalRequests < ActiveRecord::Migration[7.2]
  def change
    add_column :recurring_excusals, :evidence_link, :string
  end
end
