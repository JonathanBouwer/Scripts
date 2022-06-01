@echo off

rem This script will loop through all mkv files
rem in a directory and run mkvpropedit to change
rem the default audio and subtitle track in place

for %%f in (*.mkv) do (
echo %%f
mkvpropedit -e track:a1 -s flag-default=0 -s flag-forced=0 -e track:a2 -s flag-default=1 -e track:s1 -s flag-default=0 -s flag-forced=0 -e track:s2 -s flag-default=1 -q "%%f"
)
