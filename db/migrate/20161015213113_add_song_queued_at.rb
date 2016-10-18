# frozen_string_literal: true
class AddSongQueuedAt < ActiveRecord::Migration[5.0]
  def change
    add_column :songs, :queued_at, :datetime
  end
end
