@echo off

rem This script will search for cover art called "folder.*"
rem and then loop through all mp3 files in a directory and
rem run ffmpeg to change the cover art.
rem Output is saved in a new directory called output

FOR /F "tokens=*" %%a in ('dir /s /b folder.*') do SET folder=%%a

echo %folder%

if not exist output mkdir output
for %%f in (*.mp3) do ffmpeg -i "%%f" -i "%folder%" -map 0:0 -map 1:0 -c copy -id3v2_version 3 -metadata:s:v title="Album cover" -metadata:s:v comment="Cover (front)" "output/%%f"
