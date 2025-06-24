require 'rails_helper'

RSpec.describe Movie, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:imdb_id) }
    it { should validate_uniqueness_of(:imdb_id) }
  end

  describe 'associations' do
    it { should have_many(:programmations) }
  end

  describe 'ransackable attributes' do
    it 'includes the correct attributes' do
      expect(Movie.ransackable_attributes).to include(
        'id', 'title', 'description', 'duration', 'genre',
        'director', 'cast', 'poster_url', 'imdb_id',
        'created_at', 'updated_at'
      )
    end
  end

  describe 'ransackable associations' do
    it 'includes the correct associations' do
      expect(Movie.ransackable_associations).to include('programmations')
    end
  end
end
