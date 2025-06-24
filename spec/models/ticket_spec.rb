require 'rails_helper'

RSpec.describe Ticket, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:quantity) }
    it { should validate_presence_of(:total_price) }
    it { should validate_numericality_of(:quantity).is_greater_than(0) }
    it { should validate_numericality_of(:total_price).is_greater_than_or_equal_to(0) }
  end

  describe 'associations' do
    it { should belong_to(:programmation) }
  end

  describe 'enums' do
    it { should define_enum_for(:status).with_values(pending: 0, paid: 1, cancelled: 2) }
  end

  describe 'callbacks' do
    describe 'before_validation' do
      let(:programmation) { create(:programmation, price: 8.0) }
      let(:ticket) { build(:ticket, programmation: programmation, quantity: 2) }

      it 'calculates total_price before validation' do
        ticket.valid?
        expect(ticket.total_price).to eq(16.0)
      end
    end
  end

  describe 'ransackable attributes' do
    it 'includes the correct attributes' do
      expect(Ticket.ransackable_attributes).to include(
        'id', 'programmation_id', 'quantity', 'total_price',
        'status', 'created_at', 'updated_at'
      )
    end
  end

  describe 'ransackable associations' do
    it 'includes the correct associations' do
      expect(Ticket.ransackable_associations).to include('programmation')
    end
  end
end
