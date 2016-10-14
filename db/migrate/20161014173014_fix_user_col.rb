class FixUserCol < ActiveRecord::Migration[5.0]
  def change
    change_column :users, :spotify_attributes, :text, default: nil, :null => true
  end
end
