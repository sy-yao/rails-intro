class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  #https://stackoverflow.com/questions/9433678/ruby-array-to-hash-each-element-the-key-and-derive-value-from-it
  def index
    @movies = Movie.all
    @all_ratings = Movie.all_ratings
    @ratings_to_show = params[:ratings]&.keys || session[:ratings] || @all_ratings
    @ratings_to_show_value = Hash[@ratings_to_show.collect { |key| [key, "1"] }]
    
    #OH
    # Similary with ratings_to_show, there are three choices we could make
    # when setting values for how we want it to be sorted;
    # 1. If there is params[:sort_by], an update has been made, use it
    # 2. No params but there is session[:sort_by], use the "remembered" sort
    # 3. None, use some sort of default (would only happen if "sort" functionality has not been used)
    @sort_by= params[:sort_by] || session[:sort_by] || 'id'


    session[:ratings] = @ratings_to_show
    session[:sort_by] = params[:sort_by]


    #Movie Title sort and Release Date sort
    #ed #212, #227, #229 https://apidock.com/rails/ActionView/Helpers/UrlHelper/link_to
    if session[:sort_by].present?
      if session[:sort_by] == 'title'
        @title_class = 'hilite bg-warning'  
      end
      if session[:sort_by] == 'release_date'
        @release_date_class = 'hilite bg-warning'
      end
    end
  
    @movies = Movie.with_ratings(@ratings_to_show).order @sort_by

    #Redirect
    #https://www.geeksforgeeks.org/ruby-hash-class/#
    if(!(params.key?(:ratings) || !(params.key?(:sort_by))))
      flash.keep
      url = movies_path(sort_by: @sort_by, ratings: @ratings_to_show_value)
      return redirect_to url
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

  private
  # Making "internal" methods private is not required, but is a common practice.
  # This helps make clear which methods respond to requests, and which ones do not.
  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end
end
