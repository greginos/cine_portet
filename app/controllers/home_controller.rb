class HomeController < ApplicationController
  def index
    @session = Session.current_or_upcoming
  
    if @session
      # Récupérer programmations et événements
      @programmations = @session.programmations.includes(:movie).order(:time)
      @events = @session.events.order(:start_time)
      
      # Combiner et trier par date
      @schedule_items = (@programmations.to_a + @events.to_a).sort_by do |item|
        item.is_a?(Programmation) ? item.time : item.start_time
      end
    end
  end
end
