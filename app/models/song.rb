# == Schema Information
#
# Table name: songs
#
#  id         :integer          not null, primary key
#  name       :string           not null
#  artist     :string           not null
#  art        :string           not null
#  duration   :integer          not null
#  uri        :string           not null
#  score      :integer          not null
#  event_id   :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Song < ApplicationRecord
  belongs_to :event
end
