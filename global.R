## Functions for shiny app

#read in ratings data
get_ratings_data = function() {
  ratings = read.fst("data/ratings_ser.dat")
}

#read in movie data
get_movie_data = function() {
  movies = read.fst("data/movies_ser.dat")
}

#create collaborative-filtering recommender model
get_cf_recommender_model = function() {
  rec_mod = readRDS("data/rec_mod.rds")
}

#precompute item-profile for genre-based recomendations
get_item_profile = function() {
  movie.profile = read.fst("data/movie_profile.dat")
}

#get selected movies
get_selected_movies = function(input) {
  #filter and arrange selected movies
  selected_movies <- movie_data %>%
    filter(movieId %in% input$movie_selection) %>%
    arrange(title) %>%
    select(-c(genres))
  
  selected_movies
}

#create user-profile for genre-based recommendations
get_user_profile = function(user.rated.ids, rating_vec_with_id) {
  #get average rating of this user
  rating_vec = rating_vec_with_id %>% pull(ratingvec)
  avg.user.rating = mean(rating_vec)
  
  #start with an empty matrix for this user:
  #each column is a genre
  genre.list = colnames(movie.profile)
  genre.list = genre.list[!genre.list %in% "movieId"]
  
  m = length(genre.list)
  up = matrix(0, ncol = m, nrow = 1,
              dimnames=list(user="user",
                            genre=genre.list))
  
  up.df = as.data.frame(up)
  
  #loop through each genre
  for (curr.genre in genre.list) {
    #which user-rated movies are in the current genre in the loop
    genre.movie.ids = movie_data %>%
      filter(movieId %in% user.rated.ids & str_detect(genres, curr.genre)) %>%
      pull(movieId)
    
    #if there are no movies in this genre rated by the user, they have no preference
    # 0 = neutral
    if (length(genre.movie.ids) == 0) {
      up.df[1, curr.genre] = 0
    } else {
      #total movies in current genre rated by this user
      norm.total = length(genre.movie.ids)
      
      #get the sum of the normalized ratings for the movies in this genre rated by the user
      norm.rating = rating_vec_with_id %>%
        filter(movieId %in% genre.movie.ids) %>%
        mutate(normed.rating = ratingvec - avg.user.rating) %>%
        pull(normed.rating) %>%
        sum()
      
      #get the average: divide sum by the total number of movies in this genre rated by the user
      up.df[1, curr.genre] = norm.rating / norm.total      
    }
  }
  
  # convert user profile and new movie profile to matrices
  up.vector = as.numeric(up.df[1,])
  
  up.vector
}

#function for getting output info for top recommended movies
get_ratings_stats = function(top.movieIds) {
  ratings_stats <- get_ratings_data() %>% 
  filter(movieId %in% top.movieIds) %>%
  group_by(movieId) %>% 
  summarise(count = n(), avg_rating = round(mean(rating), 2)) %>% 
  select(movieId, count, avg_rating)
  
  ratings_stats
}