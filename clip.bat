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

set filename=%arg:~0,-22%.mkv
set rawstart=%arg:~-20,-11%
set rawend=%arg:~-10,-1%
set start=00:%arg:~-20,-18%:%arg:~-17,-11%
set end=00:%arg:~-10,-8%:%arg:~-7,-1%

echo ffmpeg -loglevel error -i "%filename%" -pix_fmt yuv420p -ss %start% -to %end% -crf 21 -preset slow -c:v libx264 -c:a mp3 out[%rawstart%-%rawend%].mp4
if "%1"=="" (goto loop)

:end
PAUSE