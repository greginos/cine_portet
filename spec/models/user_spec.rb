require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:first_name) }
    it { should validate_presence_of(:family_name) }
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email) }
    it { should allow_value('user@example.com').for(:email) }
    it { should_not allow_value('invalid_email').for(:email) }
  end

  describe 'associations' do
    it { should have_many(:programmation_staff) }
    it { should have_many(:staffed_programmations).through(:programmation_staff).source(:programmation) }
  end

  describe '#full_name' do
    let(:user) { build(:user, first_name: 'John', family_name: 'Doe') }

    it 'returns the full name when first_name and family_name are present' do
      expect(user.full_name).to eq('John Doe')
    end

    it 'returns the email when first_name or family_name is missing' do
      user.first_name = nil
      expect(user.full_name).to eq(user.email)
    end
  end

  describe '#staffed_programmations_by_role' do
    let(:user) { create(:user) }
    let(:programmation) { create(:programmation) }
    let!(:staff) { create(:programmation_staff, user: user, programmation: programmation, role: :projectionist) }

    it 'returns programmations for a specific role' do
      expect(user.staffed_programmations_by_role(:projectionist)).to include(programmation)
    end

    it 'does not return programmations for other roles' do
      expect(user.staffed_programmations_by_role(:opener)).not_to include(programmation)
    end
  end

  describe 'magic link methods' do
    let(:user) { create(:user) }

    describe '#generate_sign_in_token!' do
      it 'generates a token and sets expiration' do
        token = user.generate_sign_in_token!
        expect(token).to be_present
        expect(user.sign_in_token).to eq(token)
        expect(user.token_expires_at).to be > Time.current
      end
    end

    describe '#sign_in_token_valid?' do
      it 'returns true for valid token' do
        user.generate_sign_in_token!
        expect(user.sign_in_token_valid?).to be true
      end

      it 'returns false for expired token' do
        user.generate_sign_in_token!
        user.update(token_expires_at: 1.hour.ago)
        expect(user.sign_in_token_valid?).to be false
      end

      it 'returns false for missing token' do
        expect(user.sign_in_token_valid?).to be false
      end
    end

    describe '#invalidate_sign_in_token!' do
      it 'clears the token and expiration' do
        user.generate_sign_in_token!
        user.invalidate_sign_in_token!
        expect(user.sign_in_token).to be_nil
        expect(user.token_expires_at).to be_nil
      end
    end
  end
end
