class Admin::ProgrammationsController < ApplicationController
  def index
    @programmations = Programmation.all
  end

  def new
    @programmation = Programmation.new
  end

  def create
    @programmation = Programmation.new(programmation_params)
    if @programmation.save
      @programmation.fetch_movie_details if @programmation.tmdb_id.present?
      redirect_to admin_programmations_path, notice: "Programmation cr\u00E9\u00E9e avec succ\u00E8s."
    else
      render :new
    end
  end

  def search_movies
    @movies = Programmation.search_tmdb(params[:query])
    render json: @movies
  end

  private

  def programmation_params
    params.require(:programmation).permit(:tmdb_id, :date, :heure)
  end
end
