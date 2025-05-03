class AdminUser < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :validatable
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :validatable

  # Ajout des attributs recherchables pour Active Admin
  def self.ransackable_attributes(auth_object = nil)
    %w[
      created_at
      email
      encrypted_password
      id
      id_value
      remember_created_at
      reset_password_sent_at
      reset_password_token
      updated_at
    ]
  end

  # Ajout des associations recherchables pour Active Admin
  def self.ransackable_associations(auth_object = nil)
    []
  end
end
