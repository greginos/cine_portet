class HomeController < ApplicationController
  def index
    @programmations = Programmation.where("time > ?", Time.current)
                                  .order(:time)
                                  .limit(3)
  end
end
