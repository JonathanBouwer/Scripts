@echo off

rem This script loop through all jpg files in a directory and
rem run ffmpeg to crop the images to the provided dimensions
rem (W: width, H: height, X & Y: coordinates of top left of image)
rem Output is saved in a new directory called output

SET W=1340
SET H=1080
SET X=296
SET Y=0

if not exist output mkdir output
for %%f in (*.jpg) do (
echo %%f
start /B ffmpeg -loglevel panic -i "%%f" -q:v 2 -vf "crop=%W%:%H%:%X%:%Y%" "output/%%f"
)