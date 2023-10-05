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
    
    #ed #220 and #223
    if params[:ratings].present?
      @ratings_to_show = []

      params[:ratings].each do |rating|
        @ratings_to_show.append(rating)
        #session[:rating] = @ratings_to_show
        @movies = Movie.with_ratings(@ratings_to_show)
        
        #@ratings_to_show_value = Hash[@ratings_to_show.map{|key| [key,'1']}]
      end
      
      @ratings_to_show = params[:ratings]

    else
      @ratings_to_show = @all_ratings
      @movies = Movie.with_ratings(@ratings_to_show)

      #@ratings_to_show_value = Hash[@ratings_to_show.map{|key| [key,'1']}]
    end

    #ed #212, #227, #229 https://apidock.com/rails/ActionView/Helpers/UrlHelper/link_to
    if params[:sort_by].present?

      if params[:sort_by] == 'title'
        @title_class = 'hilite bg-warning'
      end

      if params[:sort_by] == 'release_date'
        @release_date_class = 'hilite bg-warning'
      end

      @movies = @movies.order(params[:sort_by])
    end

    session[:ratings] = @ratings_to_show
    session[:sort_by] = params[:sort_by]
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
