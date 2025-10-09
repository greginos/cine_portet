class Session < ApplicationRecord
  validates :name, presence: true
  validates :start_date, :end_date, presence: true
  validate :end_date_after_start_date

  has_many :programmations, dependent: :nullify
  has_many :movies, through: :programmations

  scope :current, -> { where("start_date <= ? AND end_date >= ?", Date.current, Date.current) }
  scope :upcoming, -> { where("start_date > ?", Date.current) }
  scope :past, -> { where("end_date < ?", Date.current) }
  scope :ordered, -> { order(start_date: :desc) }

  def self.ransackable_attributes(auth_object = nil)
    %w[name start_date end_date description created_at updated_at id]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[programmations movies]
  end

  def current?
    Date.current.between?(start_date, end_date)
  end

  def upcoming?
    start_date > Date.current
  end

  def past?
    end_date < Date.current
  end

  def status
    return :current if current?
    return :upcoming if upcoming?
    :past
  end

  def duration_in_days
    (end_date - start_date).to_i + 1
  end

  def total_programmations
    programmations.count
  end

  def total_tickets_sold
    programmations.joins(:tickets).where(tickets: { status: :paid }).sum("tickets.quantity")
  end

  def link_orphan_programmations
    programmations = Programmation.without_session
                                  .where("time >= ? AND time <= ?", start_date.beginning_of_day, end_date.end_of_day)

    count = programmations.update_all(session_id: id)
    count
  end

  def self.link_all_orphan_programmations
    total = 0
    Session.all.each do |session|
      count = session.link_orphan_programmations
      total += count
      puts "Session '#{session.name}': #{count} programmation(s) liée(s)"
    end
    puts "Total: #{total} programmation(s) liée(s)"
    total
  end

  private

  def end_date_after_start_date
    return if end_date.blank? || start_date.blank?

    if end_date < start_date
      errors.add(:end_date, "doit être après la date de début")
    end
  end
end
