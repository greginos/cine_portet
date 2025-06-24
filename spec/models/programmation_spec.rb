require 'rails_helper'

RSpec.describe Programmation, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:time) }
    it { should validate_presence_of(:max_tickets) }
    it { should validate_presence_of(:price) }
    it { should validate_numericality_of(:max_tickets).is_greater_than(0) }
    it { should validate_numericality_of(:price).is_greater_than_or_equal_to(0) }
  end

  describe 'associations' do
    it { should belong_to(:movie) }
    it { should have_many(:programmation_staffs).dependent(:destroy) }
    it { should have_many(:staff).through(:programmation_staffs).source(:user) }
    it { should have_many(:tickets).dependent(:destroy) }
  end

  describe 'callbacks' do
    describe 'before_validation' do
      let(:movie) { create(:movie) }
      let(:programmation) { build(:programmation, movie: movie) }

      it 'does not create a movie if imdb_id is not present' do
        expect { programmation.valid? }.not_to change(Movie, :count)
      end

      context 'when imdb_id is present' do
        let(:programmation) { build(:programmation, imdb_id: 'tt1234567') }

        it 'creates a movie from imdb_id' do
          expect(MovieService).to receive(:fetch_movie_details).with('tt1234567').and_return(
            {
              title: 'Test Movie',
              description: 'Test Description',
              duration: 120,
              genre: 'Action',
              director: 'Test Director',
              cast: 'Test Cast',
              poster_url: 'https://example.com/poster.jpg'
            }
          )

          expect { programmation.valid? }.to change(Movie, :count).by(1)
          expect(programmation.movie.title).to eq('Test Movie')
        end
      end
    end
  end

  describe 'ransackable attributes' do
    it 'includes the correct attributes' do
      expect(Programmation.ransackable_attributes).to include(
        'id', 'movie_id', 'time', 'max_tickets', 'price',
        'created_at', 'updated_at'
      )
    end
  end

  describe 'ransackable associations' do
    it 'includes the correct associations' do
      expect(Programmation.ransackable_associations).to include(
        'movie', 'programmation_staffs', 'staff', 'tickets'
      )
    end
  end
end
