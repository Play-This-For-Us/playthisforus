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
  subject { FactoryGirl.create(:vote) }

  it "is valid with valid attributes" do
    expect(subject).to be_valid
  end

  it "is not valid without a user_identifier" do
    subject.user_identifier = nil
    expect(subject).to_not be_valid
  end

  it "is not valid without a song" do
    subject.song = nil
    expect(subject).to_not be_valid
  end

  it "is not valid without a vote" do
    subject.vote = nil
    expect(subject).to_not be_valid
  end

  it "is valid with downvote" do
    subject.vote = -1
    expect(subject).to be_valid
  end

  it "is valid with upvote" do
    subject.vote = 1
    expect(subject).to be_valid
  end

  it "is not valid with too large upvote" do
    subject.vote = 2
    expect(subject).to_not be_valid
  end

  it "is not valid with too large downvote" do
    subject.vote = -2
    expect(subject).to_not be_valid
  end
end
