@echo off

rem This script will search for cover art called "folder.*"
rem and then loop through all flacfiles in a directory and
rem run ffmpeg to convert them to mp3 and change the cover art.
rem Output is saved in a new directory called output

FOR /F "tokens=*" %%a in ('dir /s /b folder.*') do SET folder=%%a

echo %folder%

if not exist output mkdir output
for %%f in (*.flac) do (
echo %%f
ffmpeg -loglevel panic -i "%%f" -ab 320k -map_metadata 0 -id3v2_version 3 "%%~nf.mp3"
ffmpeg -loglevel panic -i "%%~nf.mp3" -i "%folder%" -map 0:0 -map 1:0 -c copy -id3v2_version 3 -metadata:s:v title="Album cover" -metadata:s:v comment="Cover (front)" "output/%%~nf.mp3"
del "%%~nf.mp3"
)