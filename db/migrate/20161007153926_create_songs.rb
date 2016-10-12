# frozen_string_literal: true
class CreateSongs < ActiveRecord::Migration[5.0]
  def change
    create_table :songs do |t|
      t.string :name, null: false
      t.string :artist, null: false
      t.string :art, null: false
      t.integer :duration, limit: 4, null: false
      t.string :uri, null: false
      t.integer :score, limit: 2, null: false
      t.references :event, foreign_key: true, null: false

      t.timestamps
    end
  end
end
