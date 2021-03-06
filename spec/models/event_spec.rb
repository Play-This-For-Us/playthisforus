# frozen_string_literal: true
# == Schema Information
#
# Table name: events
#
#  id                  :integer          not null, primary key
#  name                :string           not null
#  description         :text             not null
#  join_code           :string           not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  user_id             :integer
#  spotify_playlist_id :string
#  currently_playing   :boolean          default(FALSE), not null
#  pnator_enabled      :boolean
#  pnator_danceability :float
#  pnator_energy       :float
#  pnator_popularity   :float
#  pnator_speechiness  :float
#  pnator_happiness    :float
#  image_url           :text
#

require 'rails_helper'

RSpec.describe Event, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
