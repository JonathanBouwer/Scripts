# Jonathans Scripts

This is a repository for a bunch of arbitrary scripts I use for file management and the like. Only tested for windows but I'm sure it could be ported to linux without problems

The scripts probably depend on ffmpeg or python

image_combiner needs to be compiled with a C compiler, usage is passing in 3 arguments: A file with a list of images to combine into a grid, the number of rows, the number of columns

query_anime_movies will search through all movies available on [Ster-Kinekor's](https://www.sterkinekor.com/), filter them by animation, then query [Anilist](https://anilist.co/) to determine if they are Japanese anime movies (as opposed to Western animated films). It uses a couple metrics like title accuracy, movie duration and staff to determine that. It likely has false positives and false negatives. 

Ster-Kinikor does not have an API (to my knowledge) so I am mimicking how the browser queries. You can find your own JWT by looking at the network tab for the `https://www.sterkinekor.com/middleware/api/v2/movies` request and inspecting the headers for the `x-session` parameter. This means it will probably break at some point in the future.