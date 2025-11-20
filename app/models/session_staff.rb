class SessionStaff < ApplicationRecord
  belongs_to :session
  belongs_to :user

  enum :position, {
    start_session: 0,
    end_session: 1
  }

  validates :user_id, uniqueness: { scope: [ :session_id, :position ] }

  # Pour l'affichage du nom de position
  def position_name
    I18n.t("session_staff.positions.#{position}")
  end
end
