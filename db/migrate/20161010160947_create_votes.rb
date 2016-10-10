class CreateVotes < ActiveRecord::Migration[5.0]
  def change
    create_table :votes do |t|
      t.string :user_identifier, null: false
      t.integer :vote, null: false
      t.references :song, foreign_key: true, null: false, index: true

      t.timestamps
    end
  end
end
