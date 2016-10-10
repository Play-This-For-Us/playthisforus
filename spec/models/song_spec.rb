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
#  event_id   :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'rails_helper'

RSpec.describe Song, type: :model do
  subject { FactoryGirl.create(:song) }

  it "is valid with valid attributes" do
    expect(subject).to be_valid
  end

  context "scopes" do
    it "upvotes" do
      expect(subject.votes.upvotes).to be 0
    end

    it "downvotes" do
      expect(subject.votes.downvotes).to be 0
    end
  end

  context "voting" do
    it "is able to upvote" do
      subject.upvote("1234")
      expect(subject.votes.upvotes).to be 1
    end

    it "is able to downvote" do
      subject.downvote("1234")
      expect(subject.votes.downvotes).to be 1
    end

    it "is able to change upvote to downvote" do
      subject.upvote("1234")
      expect(subject.votes.upvotes).to be 1
      expect(subject.votes.downvotes).to be 0
      subject.downvote("1234")
      expect(subject.votes.upvotes).to be 0
      expect(subject.votes.downvotes).to be 1
    end

    it "is able to change downvote to upvote" do
      subject.downvote("1234")
      expect(subject.votes.upvotes).to be 0
      expect(subject.votes.downvotes).to be 1
      subject.upvote("1234")
      expect(subject.votes.upvotes).to be 1
      expect(subject.votes.downvotes).to be 0
    end

    it "calculates vote value" do
      subject.upvote("1234")
      expect(subject.score).to be 1
      subject.upvote("12345")
      expect(subject.score).to be 2
      subject.upvote("123456")
      expect(subject.score).to be 3
      subject.downvote("4321")
      expect(subject.score).to be 2
      subject.downvote("54321")
      expect(subject.score).to be 1
      subject.downvote("654321")
      expect(subject.score).to be 0
      subject.downvote("7654321")
      expect(subject.score).to be -1
    end
  end
end
