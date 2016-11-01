# frozen_string_literal: true
class AddSavedPlaylistIdToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :saved_playlist_id, :string
  end
end
