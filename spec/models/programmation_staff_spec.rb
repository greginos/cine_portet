require 'rails_helper'

RSpec.describe ProgrammationStaff, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:role) }
    it { should validate_uniqueness_of(:user_id).scoped_to(:programmation_id, :role) }
  end

  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:programmation) }
  end

  describe 'enums' do
    it { should define_enum_for(:role).with_values(projectionist: 0, opener: 1, ticket_seller: 2) }
  end

  describe '#role_name' do
    let(:staff) { build(:programmation_staff, role: :projectionist) }

    it 'returns the French name for the role' do
      expect(staff.role_name).to eq('Projectionniste')
    end
  end
end
