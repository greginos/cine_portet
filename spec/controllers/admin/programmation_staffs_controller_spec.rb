require 'rails_helper'

RSpec.describe Admin::ProgrammationStaffsController, type: :controller do
  let(:admin_user) { create(:admin_user) }
  let(:programmation) { create(:programmation) }
  let(:user) { create(:user) }
  let(:valid_attributes) { { user_id: user.id, programmation_id: programmation.id, role: :projectionist } }
  let(:invalid_attributes) { { user_id: nil } }

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
    let(:programmation_staff) { create(:programmation_staff, programmation: programmation, user: user) }

    it 'returns a success response' do
      get :show, params: { id: programmation_staff.id }
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
    let(:programmation_staff) { create(:programmation_staff, programmation: programmation, user: user) }

    it 'returns a success response' do
      get :edit, params: { id: programmation_staff.id }
      expect(response).to be_successful
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new ProgrammationStaff' do
        expect {
          post :create, params: { programmation_staff: valid_attributes }
        }.to change(ProgrammationStaff, :count).by(1)
      end

      it 'redirects to the created programmation_staff' do
        post :create, params: { programmation_staff: valid_attributes }
        expect(response).to redirect_to(admin_programmation_staff_path(ProgrammationStaff.last))
      end
    end

    context 'with invalid params' do
      it 'does not create a new ProgrammationStaff' do
        expect {
          post :create, params: { programmation_staff: invalid_attributes }
        }.not_to change(ProgrammationStaff, :count)
      end

      it 're-renders the new template' do
        post :create, params: { programmation_staff: invalid_attributes }
        expect(response).to render_template(:new)
      end
    end
  end

  describe 'PUT #update' do
    let(:programmation_staff) { create(:programmation_staff, programmation: programmation, user: user) }

    context 'with valid params' do
      let(:new_attributes) { { role: :manager } }

      it 'updates the requested programmation_staff' do
        put :update, params: { id: programmation_staff.id, programmation_staff: new_attributes }
        programmation_staff.reload
        expect(programmation_staff.role).to eq('manager')
      end

      it 'redirects to the programmation_staff' do
        put :update, params: { id: programmation_staff.id, programmation_staff: new_attributes }
        expect(response).to redirect_to(admin_programmation_staff_path(programmation_staff))
      end
    end

    context 'with invalid params' do
      it 'does not update the programmation_staff' do
        put :update, params: { id: programmation_staff.id, programmation_staff: invalid_attributes }
        expect(response).to render_template(:edit)
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:programmation_staff) { create(:programmation_staff, programmation: programmation, user: user) }

    it 'destroys the requested programmation_staff' do
      expect {
        delete :destroy, params: { id: programmation_staff.id }
      }.to change(ProgrammationStaff, :count).by(-1)
    end

    it 'redirects to the programmation_staffs list' do
      delete :destroy, params: { id: programmation_staff.id }
      expect(response).to redirect_to(admin_programmation_staffs_path)
    end
  end
end
