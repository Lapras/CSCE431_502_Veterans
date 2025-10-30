# frozen_string_literal: true

class AddEvidenceLinkToExcusalRequests < ActiveRecord::Migration[7.2]
  def change
    add_column :excusal_requests, :evidence_link, :string
  end
end
