@echo off

rem This script will loop through all mp3 files 
rem in a directory and run ffmpeg to change convert
rem them to 320kbps mp3
rem Output is saved in a new directory called output

mkdir output
for %%f in (*.mp3) do ffmpeg -i "%%f" -ab 320k -map_metadata 0 -id3v2_version 3 "output/%%f"
