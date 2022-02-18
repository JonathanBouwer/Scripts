@echo off

rem This script take a command line argument of a file name of an
rem already clipped video using the mpv-webm extension. It extracts
rem the original filename, start and end and outputs command to
rem  encode with ffmpeg to fix any encoding glitches from mpv-webm.
rem This script makes a lot of assumptions (mkv, <1 hour, etc) but
rem prints the ffmpeg command which can be edited later.

if "%1" == "" (set /p arg="Enter clip file name: ") else (set arg=%*)

set filename=%arg:~0,-22%.mkv
set rawstart=%arg:~-20,-11%
set rawend=%arg:~-10,-1%
set start=00:%arg:~-20,-18%:%arg:~-17,-11%
set end=00:%arg:~-10,-8%:%arg:~-7,-1%

echo ffmpeg -loglevel error -i "%filename%" -c:v libx264 -c:a mp3 -pix_fmt yuv420p -ss %start% -to %end% -crf 21 out[%rawstart%-%rawend%].mp4
PAUSE