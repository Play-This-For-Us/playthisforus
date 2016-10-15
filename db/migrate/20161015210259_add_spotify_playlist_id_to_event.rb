class AddSpotifyPlaylistIdToEvent < ActiveRecord::Migration[5.0]
  def change
    add_column :events, :spotify_playlist_id, :string
  end
end
