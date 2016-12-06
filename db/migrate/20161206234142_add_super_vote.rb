class AddSuperVote < ActiveRecord::Migration[5.0]
  def change
      add_column :votes, :super_vote, :boolean, null: false, default: false
  end
end
