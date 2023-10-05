class Movie < ActiveRecord::Base
  
  def self.with_ratings(ratings_list)
    # if ratings_list is an array such as ['G', 'PG', 'R'], retrieve all
    #  movies with those ratings
    if ratings_list.nil?
      return Movie.all_ratings
    else     
      return Movie.where(rating: ratings_list)
    end
end
  
  def self.all_ratings
    
    return ['G', 'PG', 'R', 'PG-13']
  end

end
