# == Schema Information
#
# Table name: votes
#
#  id              :integer          not null, primary key
#  user_identifier :string           not null
#  vote            :integer          not null
#  song_id         :integer          not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

require 'rails_helper'

RSpec.describe Vote, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
