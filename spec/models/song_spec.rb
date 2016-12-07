# frozen_string_literal: true
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
#  queued_at  :datetime
#  super_vote :boolean          default(FALSE), not null
#

require 'rails_helper'

RSpec.describe Song, type: :model do
  subject { FactoryGirl.create(:song) }

  it 'is valid with valid attributes' do
    expect(subject).to be_valid
  end

  context 'scopes' do
    it 'upvotes' do
      expect(subject.votes.upvotes).to be 0
    end

    it 'downvotes' do
      expect(subject.votes.downvotes).to be 0
    end

    context 'ranked' do
      let(:event) { FactoryGirl.create(:event) }

      it 'handles no songs' do
        expect(event.songs.count).to be 0
        expect(event.songs.ranked).to be_empty
      end

      it 'handles song with no votes' do
        song = FactoryGirl.create(:song, event: event)
        expect(song.score).to be 0
        expect(event.songs.ranked).to match [song]
      end

      it 'properly ranks three songs' do
        song_a = FactoryGirl.create(:song, event: event)
        FactoryGirl.create(:vote, vote: 1, song: song_a)
        FactoryGirl.create(:vote, vote: 1, song: song_a)
        expect(song_a.score).to be 2

        song_d = FactoryGirl.create(:song, event: event)
        FactoryGirl.create(:vote, vote: -1, song: song_d)
        expect(song_d.score).to be(-1)

        song_c = FactoryGirl.create(:song, event: event)
        expect(song_c.score).to be 0

        song_b = FactoryGirl.create(:song, event: event)
        FactoryGirl.create(:vote, vote: 1, song: song_b)
        expect(song_b.score).to be 1

        expect(event.songs.ranked).to match [song_a, song_b, song_c, song_d]
      end

      it 'properly ranks vote ties' do
        song_a = FactoryGirl.create(:song, event: event)
        FactoryGirl.create(:vote, vote: 1, song: song_a)
        FactoryGirl.create(:vote, vote: 1, song: song_a)
        expect(song_a.score).to be 2

        song_d = FactoryGirl.create(:song, event: event, created_at: Date.parse('31-12-1990'))
        FactoryGirl.create(:vote, vote: 1, song: song_d)
        FactoryGirl.create(:vote, vote: 1, song: song_d)
        expect(song_d.score).to be 2

        song_c = FactoryGirl.create(:song, event: event)
        expect(song_c.score).to be 0

        song_b = FactoryGirl.create(:song, event: event)
        FactoryGirl.create(:vote, vote: 1, song: song_b)
        expect(song_b.score).to be 1

        expect(event.songs.ranked).to match [song_d, song_a, song_b, song_c]
      end

      it 'properly ranks super votes first' do
        song_a = FactoryGirl.create(:song, event: event, super_vote: false)
        expect(song_a.score).to be 0

        song_c = FactoryGirl.create(:song, event: event, super_vote: true)
        expect(song_c.score).to be 0

        song_b = FactoryGirl.create(:song, event: event, super_vote: false)
        FactoryGirl.create(:vote, vote: 1, song: song_b)
        expect(song_b.score).to be 1

        expect(event.songs.ranked).to match [song_c, song_b, song_a]
      end

      it 'properly ranks super votes by actual vote value when multiple super upvotes' do
        song_a = FactoryGirl.create(:song, event: event, super_vote: true)
        FactoryGirl.create(:vote, vote: -1, song: song_a)
        FactoryGirl.create(:vote, vote: -1, song: song_a)
        expect(song_a.score).to be -2

        song_d = FactoryGirl.create(:song, event: event, super_vote: true)
        FactoryGirl.create(:vote, vote: 1, song: song_d)
        FactoryGirl.create(:vote, vote: 1, song: song_d)
        expect(song_d.score).to be 2

        song_c = FactoryGirl.create(:song, event: event, super_vote: true)
        FactoryGirl.create(:vote, vote: 1, song: song_c)
        expect(song_c.score).to be 1

        song_b = FactoryGirl.create(:song, event: event, super_vote: true)
        expect(song_b.score).to be 0

        expect(event.songs.ranked).to match [song_d, song_c, song_b, song_a]
      end
    end
  end

  context 'voting' do
    it 'is able to upvote' do
      subject.upvote('1234')
      expect(subject.votes.upvotes).to be 1
    end

    it 'is able to downvote' do
      subject.downvote('1234')
      expect(subject.votes.downvotes).to be 1
    end

    it 'is able to change upvote to downvote' do
      subject.upvote('1234')
      expect(subject.votes.upvotes).to be 1
      expect(subject.votes.downvotes).to be 0
      subject.downvote('1234')
      expect(subject.votes.upvotes).to be 0
      expect(subject.votes.downvotes).to be 1
    end

    it 'is able to change downvote to upvote' do
      subject.downvote('1234')
      expect(subject.votes.upvotes).to be 0
      expect(subject.votes.downvotes).to be 1
      subject.upvote('1234')
      expect(subject.votes.upvotes).to be 1
      expect(subject.votes.downvotes).to be 0
    end

    it 'calculates vote value' do
      subject.upvote('1234')
      expect(subject.score).to be 1
      subject.upvote('12345')
      expect(subject.score).to be 2
      subject.upvote('123456')
      expect(subject.score).to be 3
      subject.downvote('4321')
      expect(subject.score).to be 2
      subject.downvote('54321')
      expect(subject.score).to be 1
      subject.downvote('654321')
      expect(subject.score).to be 0
      subject.downvote('7654321')
      expect(subject.score).to be(-1)
    end
  end
end
