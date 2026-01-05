class Event < ApplicationRecord
  validates :title, presence: true
  validates :start_time, presence: true
  
  belongs_to :programmation, optional: true
  belongs_to :session, optional: true
  
  before_validation :auto_assign_session, if: -> { session_id.nil? }
  
  scope :upcoming, -> { where('start_time >= ?', Time.current).order(start_time: :asc) }
  scope :past, -> { where('start_time < ?', Time.current).order(start_time: :desc) }
  scope :independent, -> { where(programmation_id: nil, session_id: nil) }
  scope :linked_to_screening, -> { where.not(programmation_id: nil) }
  scope :in_session, ->(session) { where(session: session) }
  scope :without_session, -> { where(session_id: nil) }
  
  def self.ransackable_attributes(auth_object = nil)
    %w[id title description start_time programmation_id session_id created_at updated_at]
  end
  
  def self.ransackable_associations(auth_object = nil)
    %w[programmation session]
  end
  
  def linked_to_screening?
    programmation_id.present?
  end
  
  def in_session?
    session_id.present?
  end
  
  def event_type
    if programmation_id.present?
      "Lié à une projection"
    elsif session_id.present?
      "Événement de session"
    else
      "Événement indépendant"
    end
  end
  
  private
  
  # Auto-assigne la session basée sur la date de l'événement
  def auto_assign_session
    return if start_time.nil?
    
    matching_session = Session.where("start_date <= ? AND end_date >= ?", 
                                      start_time.to_date, 
                                      start_time.to_date).first
    self.session = matching_session if matching_session
  end
end