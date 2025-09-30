class MoviesController < ApplicationController
  def index
    @movies = Movie.all
  end

  def show
    @movie = Movie.find(params[:id])
    @programmation = Programmation.find(params[:programmation])
  end
end
