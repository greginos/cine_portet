class ProgrammationsController < ApplicationController
  def index
    @programmations = Programmation.where("time > ?", Time.current).order(:time)
  end

  def show
    @programmation = Programmation.find(params[:id])
  end
end
