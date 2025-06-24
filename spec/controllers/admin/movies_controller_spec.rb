require 'rails_helper'

RSpec.describe Admin::MoviesController, type: :controller do
  let(:admin_user) { create(:admin_user) }
  let(:valid_attributes) { attributes_for(:movie) }
  let(:invalid_attributes) { { title: '' } }

  before do
    sign_in admin_user
  end

  describe 'GET #index' do
    it 'returns a success response' do
      get :index
      expect(response).to be_successful
    end
  end

  describe 'GET #show' do
    let(:movie) { create(:movie) }

    it 'returns a success response' do
      get :show, params: { id: movie.id }
      expect(response).to be_successful
    end
  end

  describe 'GET #new' do
    it 'returns a success response' do
      get :new
      expect(response).to be_successful
    end
  end

  describe 'GET #edit' do
    let(:movie) { create(:movie) }

    it 'returns a success response' do
      get :edit, params: { id: movie.id }
      expect(response).to be_successful
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new Movie' do
        expect {
          post :create, params: { movie: valid_attributes }
        }.to change(Movie, :count).by(1)
      end

      it 'redirects to the created movie' do
        post :create, params: { movie: valid_attributes }
        expect(response).to redirect_to(admin_movie_path(Movie.last))
      end
    end

    context 'with invalid params' do
      it 'does not create a new Movie' do
        expect {
          post :create, params: { movie: invalid_attributes }
        }.not_to change(Movie, :count)
      end

      it 're-renders the new template' do
        post :create, params: { movie: invalid_attributes }
        expect(response).to render_template(:new)
      end
    end
  end

  describe 'PUT #update' do
    let(:movie) { create(:movie) }

    context 'with valid params' do
      let(:new_attributes) { { title: 'New Title' } }

      it 'updates the requested movie' do
        put :update, params: { id: movie.id, movie: new_attributes }
        movie.reload
        expect(movie.title).to eq('New Title')
      end

      it 'redirects to the movie' do
        put :update, params: { id: movie.id, movie: new_attributes }
        expect(response).to redirect_to(admin_movie_path(movie))
      end
    end

    context 'with invalid params' do
      it 'does not update the movie' do
        put :update, params: { id: movie.id, movie: invalid_attributes }
        expect(response).to render_template(:edit)
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:movie) { create(:movie) }

    it 'destroys the requested movie' do
      expect {
        delete :destroy, params: { id: movie.id }
      }.to change(Movie, :count).by(-1)
    end

    it 'redirects to the movies list' do
      delete :destroy, params: { id: movie.id }
      expect(response).to redirect_to(admin_movies_path)
    end
  end
end
