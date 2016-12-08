class AddSuperVote < ActiveRecord::Migration[5.0]
  def change
    add_column :songs, :super_vote, :boolean, null: false, default: false
  end
end
