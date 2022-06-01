# Jonathan's Scripts

This is a repository for a bunch of arbitrary scripts I use for file management and the like. Also Bad Apple. Only tested for Windows but I'm sure it could be ported to Linux without problems.

The scripts probably depend on ffmpeg or Python.

### Image Combiner

image_combiner needs to be compiled with a C compiler, usage is passing in 3 arguments: A file with a list of images to combine into a grid, the number of rows, the number of columns.

### Bad Apple

`bad_apple.py` is a Python implementation of a simple video renderer for the terminal. It uses `raw_bad_apple.bin` as data. 

That file contains a stream of bytes such that each byte represents the brightness of a pixel (0-256). The video itself has a resolution of 72x54, frame rate of 30FPS and is 6569 frames long. Each frame's first pixel in the bottom left hand corner and is saved row by row going right and upwards. 

`raw_bad_apple.bin` was generated using the following procedure:
* Use ffmpeg command to dump frames of the source video as BMP files. Something like `ffmpeg -i bad_apple.mkv -vf scale=72:54,fps=30 out/%4d.bmp`
* Use a python script to parse each of the pixels into an average value
* Dumping that data raw into the binary file.

That script was not saved into this repository nor were the BMP images.

### Query Anime Movies

`query_anime_movies.py` will search through all movies available on [Ster-Kinekor's](https://www.sterkinekor.com/), filter them by animation, then query [Anilist](https://anilist.co/) to determine if they are Japanese anime movies (as opposed to Western animated films). It uses a couple metrics like title accuracy, movie duration and staff to determine that. It likely has false positives and false negatives. 

Ster-Kinikor does not have an API (to my knowledge) so I use web scraping. You can find your own JWT by looking at the network tab for the `https://www.sterkinekor.com/middleware/api/v2/movies` request and inspecting the headers for the `x-session` parameter. This also means it will probably break at some point in the future.