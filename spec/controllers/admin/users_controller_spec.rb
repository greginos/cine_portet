require 'rails_helper'

RSpec.describe Admin::UsersController, type: :controller do
  let(:admin_user) { create(:admin_user) }
  let(:valid_attributes) { attributes_for(:user) }
  let(:invalid_attributes) { { email: '' } }

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
    let(:user) { create(:user) }

    it 'returns a success response' do
      get :show, params: { id: user.id }
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
    let(:user) { create(:user) }

    it 'returns a success response' do
      get :edit, params: { id: user.id }
      expect(response).to be_successful
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new User' do
        expect {
          post :create, params: { user: valid_attributes }
        }.to change(User, :count).by(1)
      end

      it 'redirects to the created user' do
        post :create, params: { user: valid_attributes }
        expect(response).to redirect_to(admin_user_path(User.last))
      end
    end

    context 'with invalid params' do
      it 'does not create a new User' do
        expect {
          post :create, params: { user: invalid_attributes }
        }.not_to change(User, :count)
      end

      it 're-renders the new template' do
        post :create, params: { user: invalid_attributes }
        expect(response).to render_template(:new)
      end
    end
  end

  describe 'PUT #update' do
    let(:user) { create(:user) }

    context 'with valid params' do
      let(:new_attributes) { { first_name: 'New Name' } }

      it 'updates the requested user' do
        put :update, params: { id: user.id, user: new_attributes }
        user.reload
        expect(user.first_name).to eq('New Name')
      end

      it 'redirects to the user' do
        put :update, params: { id: user.id, user: new_attributes }
        expect(response).to redirect_to(admin_user_path(user))
      end
    end

    context 'with invalid params' do
      it 'does not update the user' do
        put :update, params: { id: user.id, user: invalid_attributes }
        expect(response).to render_template(:edit)
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:user) { create(:user) }

    it 'destroys the requested user' do
      expect {
        delete :destroy, params: { id: user.id }
      }.to change(User, :count).by(-1)
    end

    it 'redirects to the users list' do
      delete :destroy, params: { id: user.id }
      expect(response).to redirect_to(admin_users_path)
    end
  end

  describe 'POST #send_magic_link' do
    let(:user) { create(:user) }

    it 'generates a sign in token and sends an email' do
      expect {
        post :send_magic_link, params: { id: user.id }
      }.to change { user.reload.sign_in_token }.from(nil)
      expect(response).to redirect_to(admin_user_path(user))
    end
  end
end
