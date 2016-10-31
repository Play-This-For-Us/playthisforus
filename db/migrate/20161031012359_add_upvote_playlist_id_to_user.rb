# frozen_string_literal: true
class AddUpvotePlaylistIdToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :upvote_playlist_id, :string
  end
end
