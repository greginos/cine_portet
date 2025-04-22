class Staff::ProgrammationsController < ApplicationController
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
      redirect_to staff_programmations_path, notice: "Programmation créée avec succès."
    else
      render :new
    end
  end

  def edit
    @programmation = Programmation.find(params[:id])
  end

  def update
    @programmation = Programmation.find(params[:id])
    if @programmation.update(programmation_params)
      @programmation.fetch_movie_details if @programmation.tmdb_id.present?
      redirect_to staff_programmations_path, notice: "Programmation mise à jour avec succès."
    else
      render :edit
    end
  end

  def destroy
    @programmation = Programmation.find(params[:id])
    @programmation.destroy
    redirect_to staff_programmations_path, notice: "Programmation supprimée avec succès."
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
