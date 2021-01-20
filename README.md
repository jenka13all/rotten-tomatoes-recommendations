# Movie Recommender Shiny App

## Data and Codebase

This app uses data from MovieLens movie recommendations: movies and ratings. The data used to build the models has been removed from the code. The main GUI is largely based on the code from the following repository, but has been refactored and modified to suit this app's purpose.

[STATWORK Blog](https://github.com/STATWORX/blog/tree/master/movie_recommendation)

## Serialization

This data is preformatted and the models pre-computed and serialized in serialize_models.R, which is not used in the app itself, but here to illustrate how the data was used and how the models (item profile, recommender model) were created.

## Detailed Explanation

For a detailed explanation of the code and how it was put together, see the [Github Page](https://jenka13all.github.io/rotten-tomatoes-recommendations/).

## Code Files

* app.R is the main engine of the app. It loads all the files and contains the main GUI. 

* global.R contains functions for accessing and manipulating data. 

* load_data.R sets up the necessary components for the initial static GUI and loads the pre-computed models. 

* ui_server.R contains the code for the interactivity of the GUI 

* data_server.R integrates the user input with the models in order to make predictions.

## Running the App

The app is hosted online at shinyapps.io:

[https://jennifer-koenig-berlin.shinyapps.io/recommender/](https://jennifer-koenig-berlin.shinyapps.io/recommender/)

If you want to run the app locally, you simply need to load the code in R Studio. In the app.R file, click the "Run App" button on the upper right-hand side of the editor. The app will open in an R browser console.