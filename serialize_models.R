library(fst)
library(DT)
library(tidyverse)
library(dplyr)
library(reshape2)
library(recommenderlab)
library(data.table)
library(lsa)

serialize_ratings_data = function() {
  ratings = read.csv("ratings.dat", 
                     sep=":", 
                     colClasses = c("integer", "NULL", "integer", "NULL", "integer", "NULL"), 
                     header = FALSE
  )
  colnames(ratings) = c("userId", "movieId", "rating", "timestamp")
  
  write.fst(ratings, "data/ratings_ser.dat")
}

serialize_movie_data = function() {
  movies = readLines('movies.dat')
  movies = strsplit(movies, split = "::", fixed = TRUE, useBytes = TRUE)
  movies = matrix(unlist(movies), ncol = 3, byrow = TRUE)
  movies = data.frame(movies, stringsAsFactors = FALSE)
  colnames(movies) = c("movieId", "title", "genres")
  movies$movieId = as.integer(movies$movieId)
  
  #convert accented chars
  movies$title = iconv(movies$title, "latin1", "UTF-8")
  
  write.fst(movies, "data/movies_ser.dat")
}

serialize_cf_recommender_model = function() {
  ratings_data = read.fst("data/ratings_ser.dat")
  
  dropdown_movieId <- ratings_data %>% group_by(movieId) %>% 
    summarise(count = n()) %>% 
    filter(count > 50) %>%
    pull(movieId)
  
  ratings_data <- ratings_data %>% filter(movieId %in% dropdown_movieId)
  #make df into format rows = userId, cols = movieId, each element is a rating (or NA)
  rating_mat <- reshape2::dcast(ratings_data, 
                                userId ~ movieId, 
                                value.var = "rating", 
                                na.rm=FALSE)
  
  #cast to matrix
  rating_mat <- as.matrix(rating_mat[,-1]) 
  
  #cast matrix to realRatingMatrix for Recommender
  rating_mat <- as(rating_mat, "realRatingMatrix")
  
  #item-based collaborative filtering
  #create model
  rec_mod <- Recommender(rating_mat, 
                         method = "IBCF", 
                         param = list(method = "Cosine", 
                                      k = 30, 
                                      normalize = "center")
  )
  
  saveRDS(rec_mod, file = "data/rec_mod.rds")
}

serialize_item_profile = function() {
  movie_data = read.fst("data/movies_ser.dat")
  
  #rows = movies, columns = genre, elements = 1/0
  movie.profile = movie_data %>%
    mutate(ind = row_number()) %>%
    separate_rows(genres, sep="[|]") %>%
    mutate(genres = ifelse(is.na(genres), 0, genres)) %>%
    count(ind, genres) %>%
    spread(genres, n, fill = 0) %>%
    select(-1) %>%
    as.data.frame()
  
  #tack on movieIds so we can keep track
  movie.profile$movieId = movie_data$movieId
  
  write.fst(movie.profile, "data/movie_profile.dat")
}

#serialize_ratings_data()
#serialize_movie_data()
#serialize_cf_recommender_model()
#serialize_item_profile()