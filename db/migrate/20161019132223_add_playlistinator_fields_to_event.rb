class AddPlaylistinatorFieldsToEvent < ActiveRecord::Migration[5.0]
  def change
    add_column :events, :pnator_enabled, :boolean
    add_column :events, :pnator_danceability, :float
    add_column :events, :pnator_energy, :float
    add_column :events, :pnator_popularity, :float
    add_column :events, :pnator_speechiness, :float
    add_column :events, :pnator_happiness, :float
  end
end
