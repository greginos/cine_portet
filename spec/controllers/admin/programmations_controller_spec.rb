require 'rails_helper'

RSpec.describe Admin::ProgrammationsController, type: :controller do
  let(:admin_user) { create(:admin_user) }
  let(:movie) { create(:movie) }
  let(:valid_attributes) { attributes_for(:programmation, movie_id: movie.id) }
  let(:invalid_attributes) { { time: nil } }

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
    let(:programmation) { create(:programmation) }

    it 'returns a success response' do
      get :show, params: { id: programmation.id }
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
    let(:programmation) { create(:programmation) }

    it 'returns a success response' do
      get :edit, params: { id: programmation.id }
      expect(response).to be_successful
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new Programmation' do
        expect {
          post :create, params: { programmation: valid_attributes }
        }.to change(Programmation, :count).by(1)
      end

      it 'redirects to the created programmation' do
        post :create, params: { programmation: valid_attributes }
        expect(response).to redirect_to(admin_programmation_path(Programmation.last))
      end
    end

    context 'with invalid params' do
      it 'does not create a new Programmation' do
        expect {
          post :create, params: { programmation: invalid_attributes }
        }.not_to change(Programmation, :count)
      end

      it 're-renders the new template' do
        post :create, params: { programmation: invalid_attributes }
        expect(response).to render_template(:new)
      end
    end
  end

  describe 'PUT #update' do
    let(:programmation) { create(:programmation) }

    context 'with valid params' do
      let(:new_attributes) { { max_tickets: 150 } }

      it 'updates the requested programmation' do
        put :update, params: { id: programmation.id, programmation: new_attributes }
        programmation.reload
        expect(programmation.max_tickets).to eq(150)
      end

      it 'redirects to the programmation' do
        put :update, params: { id: programmation.id, programmation: new_attributes }
        expect(response).to redirect_to(admin_programmation_path(programmation))
      end
    end

    context 'with invalid params' do
      it 'does not update the programmation' do
        put :update, params: { id: programmation.id, programmation: invalid_attributes }
        expect(response).to render_template(:edit)
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:programmation) { create(:programmation) }

    it 'destroys the requested programmation' do
      expect {
        delete :destroy, params: { id: programmation.id }
      }.to change(Programmation, :count).by(-1)
    end

    it 'redirects to the programmations list' do
      delete :destroy, params: { id: programmation.id }
      expect(response).to redirect_to(admin_programmations_path)
    end
  end

  describe 'GET #search_movies' do
    it 'returns a success response' do
      get :search_movies, params: { q: 'test' }
      expect(response).to be_successful
    end
  end
end
