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

require 'rails_helper'

RSpec.describe Song, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
