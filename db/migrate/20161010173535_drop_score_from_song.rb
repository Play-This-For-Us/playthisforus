class DropScoreFromSong < ActiveRecord::Migration[5.0]
  def change
    remove_column :songs, :score
  end
end
