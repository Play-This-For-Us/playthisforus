class AddSpotifyHash < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :spotify_attributes, :text, default: "", null: false
  end
end
