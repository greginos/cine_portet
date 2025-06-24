require 'rails_helper'

RSpec.describe MovieService do
  describe '.fetch_movie_details' do
    let(:imdb_id) { 'tt1234567' }
    let(:api_key) { 'test_api_key' }

    before do
      allow(ENV).to receive(:[]).with('OMDB_API_KEY').and_return(api_key)
    end

    context 'when the API call is successful' do
      let(:successful_response) do
        {
          'Title' => 'Test Movie',
          'Plot' => 'Test Description',
          'Runtime' => '120 min',
          'Genre' => 'Action',
          'Director' => 'Test Director',
          'Actors' => 'Test Cast',
          'Poster' => 'https://example.com/poster.jpg'
        }
      end

      before do
        stub_request(:get, "http://www.omdbapi.com/?apikey=#{api_key}&i=#{imdb_id}")
          .to_return(status: 200, body: successful_response.to_json)
      end

      it 'returns movie details' do
        result = described_class.fetch_movie_details(imdb_id)
        expect(result).to include(
          title: 'Test Movie',
          description: 'Test Description',
          duration: 120,
          genre: 'Action',
          director: 'Test Director',
          cast: 'Test Cast',
          poster_url: 'https://example.com/poster.jpg'
        )
      end
    end

    context 'when the API call fails' do
      before do
        stub_request(:get, "http://www.omdbapi.com/?apikey=#{api_key}&i=#{imdb_id}")
          .to_return(status: 500)
      end

      it 'raises an error' do
        expect { described_class.fetch_movie_details(imdb_id) }.to raise_error(StandardError)
      end
    end

    context 'when the movie is not found' do
      before do
        stub_request(:get, "http://www.omdbapi.com/?apikey=#{api_key}&i=#{imdb_id}")
          .to_return(status: 200, body: { 'Error' => 'Movie not found!' }.to_json)
      end

      it 'raises an error' do
        expect { described_class.fetch_movie_details(imdb_id) }.to raise_error(StandardError)
      end
    end
  end
end
