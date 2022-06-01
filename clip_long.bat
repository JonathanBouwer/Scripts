@echo off

rem This script take a command line argument of a file name of an
rem already clipped video using the mpv-webm extension. It extracts
rem the original filename, start and end and outputs command to
rem encode with ffmpeg to fix any encoding glitches from mpv-webm.
rem If no argument is provided it will loop on user input.
rem This script makes a lot of assumptions (mkv, <1 hour, etc) but
rem prints the ffmpeg command which can be edited later.

:loop
set arg=
if "%1"=="" (set /p arg="Enter clip file name: ") else (set arg=%*)
if not defined arg (goto end)

set filename=%arg:~0,-26%.mkv
set rawstart=%arg:~-24,-13%
set rawend=%arg:~-12,-1%
set start=0%arg:~-24,-23%:%arg:~-22,-20%:%arg:~-19,-13%
set end=0%arg:~-12,-11%:%arg:~-10,-8%:%arg:~-7,-1%

echo ffmpeg -loglevel error -i "%filename%" -c:v libx264 -c:a mp3 -pix_fmt yuv420p -ss %start% -to %end% -crf 21 out[%rawstart%-%rawend%].mp4
if "%1"=="" (goto loop)

:end
PAUSE