require 'rails_helper'

RSpec.describe Admin::TicketsController, type: :controller do
  let(:admin_user) { create(:admin_user) }
  let(:programmation) { create(:programmation) }
  let(:valid_attributes) { attributes_for(:ticket, programmation_id: programmation.id) }
  let(:invalid_attributes) { { quantity: 0 } }

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
    let(:ticket) { create(:ticket, programmation: programmation) }

    it 'returns a success response' do
      get :show, params: { id: ticket.id }
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
    let(:ticket) { create(:ticket, programmation: programmation) }

    it 'returns a success response' do
      get :edit, params: { id: ticket.id }
      expect(response).to be_successful
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new Ticket' do
        expect {
          post :create, params: { ticket: valid_attributes }
        }.to change(Ticket, :count).by(1)
      end

      it 'redirects to the created ticket' do
        post :create, params: { ticket: valid_attributes }
        expect(response).to redirect_to(admin_ticket_path(Ticket.last))
      end
    end

    context 'with invalid params' do
      it 'does not create a new Ticket' do
        expect {
          post :create, params: { ticket: invalid_attributes }
        }.not_to change(Ticket, :count)
      end

      it 're-renders the new template' do
        post :create, params: { ticket: invalid_attributes }
        expect(response).to render_template(:new)
      end
    end
  end

  describe 'PUT #update' do
    let(:ticket) { create(:ticket, programmation: programmation) }

    context 'with valid params' do
      let(:new_attributes) { { quantity: 3 } }

      it 'updates the requested ticket' do
        put :update, params: { id: ticket.id, ticket: new_attributes }
        ticket.reload
        expect(ticket.quantity).to eq(3)
      end

      it 'redirects to the ticket' do
        put :update, params: { id: ticket.id, ticket: new_attributes }
        expect(response).to redirect_to(admin_ticket_path(ticket))
      end
    end

    context 'with invalid params' do
      it 'does not update the ticket' do
        put :update, params: { id: ticket.id, ticket: invalid_attributes }
        expect(response).to render_template(:edit)
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:ticket) { create(:ticket, programmation: programmation) }

    it 'destroys the requested ticket' do
      expect {
        delete :destroy, params: { id: ticket.id }
      }.to change(Ticket, :count).by(-1)
    end

    it 'redirects to the tickets list' do
      delete :destroy, params: { id: ticket.id }
      expect(response).to redirect_to(admin_tickets_path)
    end
  end

  describe 'PUT #mark_as_paid' do
    let(:ticket) { create(:ticket, programmation: programmation) }

    it 'updates the ticket status to paid' do
      put :mark_as_paid, params: { id: ticket.id }
      ticket.reload
      expect(ticket.status).to eq('paid')
    end

    it 'redirects to the ticket' do
      put :mark_as_paid, params: { id: ticket.id }
      expect(response).to redirect_to(admin_ticket_path(ticket))
    end
  end

  describe 'PUT #mark_as_cancelled' do
    let(:ticket) { create(:ticket, programmation: programmation) }

    it 'updates the ticket status to cancelled' do
      put :mark_as_cancelled, params: { id: ticket.id }
      ticket.reload
      expect(ticket.status).to eq('cancelled')
    end

    it 'redirects to the ticket' do
      put :mark_as_cancelled, params: { id: ticket.id }
      expect(response).to redirect_to(admin_ticket_path(ticket))
    end
  end
end
