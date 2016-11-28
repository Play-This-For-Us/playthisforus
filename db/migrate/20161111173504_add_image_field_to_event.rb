class AddImageFieldToEvent < ActiveRecord::Migration[5.0]
  def change
    add_column :events, :image_url, :text, null: true
  end
end
