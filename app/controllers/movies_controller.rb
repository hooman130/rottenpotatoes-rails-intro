class MoviesController < ApplicationController
  
  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @all_ratings = ['G', 'PG', 'PG-13', 'R']
    
    if params.has_key?(:ratings)
      @ratings = params[:ratings]
      @ratings = @ratings.keys if @ratings.respond_to?(:keys)
      if @ratings.empty?.!
        session[:ratings] = @ratings
      end
    end
    
    if params.has_key?(:sort_by)
      session[:sort_by] = params[:sort_by]
    end
    
    if (!(session[:sort_by].nil?) && !(session[:ratings].nil?))
      @movies = Movie.where(["rating IN (?)", session[:ratings]]).order(session[:sort_by])
    elsif session[:sort_by].nil? && !(session[:ratings].nil?)
      @movies = Movie.where(["rating IN (?)", session[:ratings]])
    elsif !(session[:sort_by].nil?) && session[:ratings].nil?
      @movies = Movie.order(session[:sort_by])
    else
      @movies = Movie.all
    end
    
    if session[:ratings] != params[:ratings] || session[:sort_by] != params[:sort_by]
      flash.keep
      redirect_to movies_path(ratings: session[:ratings], sort_by: session[:sort_by])
    end
 
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end
end