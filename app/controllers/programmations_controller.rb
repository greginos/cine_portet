class ProgrammationsController < ApplicationController
  def index
    @programmations = Programmation.all
    @date = params.fetch(:date, Date.today).to_date
  end
end
