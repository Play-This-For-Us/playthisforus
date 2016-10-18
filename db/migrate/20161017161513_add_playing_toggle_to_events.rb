# frozen_string_literal: true
class AddPlayingToggleToEvents < ActiveRecord::Migration[5.0]
  def change
    add_column :events, :currently_playing, :boolean, default: false, null: false
  end
end
