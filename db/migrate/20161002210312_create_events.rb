class CreateEvents < ActiveRecord::Migration[5.0]
  def change
    create_table :events do |t|
      t.string :name, null: false
      t.text :description
      t.string :join_code, null: false

      t.timestamps
    end

    add_reference :events, :user, foreign_key: true, index: true
  end
end
