@echo off

rem This script will swap track 0 and track 1 of audio and subtitles
rem and then default track 0 of both audio and subtitles in the output
rem Output is saved in a new directory called output

if not exist output mkdir output
for %%f in (*.mkv) do ffmpeg -i "%%f" -map 0:v:0 -map 0:a:1 -map 0:a:0 -map 0:s:1 -map 0:s:0 -map 0:t -c copy -disposition:a:0 default -disposition:a:1 none -disposition:s:0 default -disposition:s:1 none "output/%%f"