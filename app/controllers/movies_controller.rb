Tmdb::Api.key(ENV["API_TMDB"])

class MoviesController < ApplicationController
  before_action :force_index_redirect, only: [:index]

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @all_ratings = Movie.all_ratings
    @movies = Movie.with_ratings(ratings_list, sort_by)
    @ratings_to_show_hash = ratings_hash
    @sort_by = sort_by
    # remember the correct settings for next time
    session['ratings'] = ratings_list
    session['sort_by'] = @sort_by
  end

  def new
    # default: render 'new' template
    @movie_title = params[:name]
    @movie_rate = params[:rate]
    @movie_date = params[:date] || Date.today.strftime()
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

  def search_tmdb
    @movie = params[:movie][:title]
    find_movie = Tmdb::Movie.find(@movie)
    if !find_movie.empty?  #เช็คว่าไม่ใช่ลิสว่าง
      mov1 = find_movie[0] #หนังเรื่องแรกที่ค้นหาเจอ
      #@rating = "PG-13" เอาออก ลบการส่งด้วย
      @release_date = mov1.release_date
      @title_name = mov1.title
      redirect_to new_movie_path( name:@title_name, date:@release_date)
    else
      flash[:notice] = "'#{@movie}' was not found in TMDb."
      redirect_to movies_path
    end
  end

  private

  def force_index_redirect
    if !params.key?(:ratings) || !params.key?(:sort_by)
      flash.keep
      url = movies_path(sort_by: sort_by, ratings: ratings_hash)
      redirect_to url
    end
  end

  def ratings_list
    params[:ratings]&.keys || session[:ratings] || Movie.all_ratings
  end

  def ratings_hash
    Hash[ratings_list.collect { |item| [item, "1"] }]
  end

  def sort_by
    params[:sort_by] || session[:sort_by] || 'id'
  end

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end
end
