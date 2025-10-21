# frozen_string_literal: true

class AddNotesToEvents < ActiveRecord::Migration[7.2]
  def change
    add_column :events, :notes, :text
  end
end
