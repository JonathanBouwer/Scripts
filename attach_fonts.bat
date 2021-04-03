@echo off
if not exist output mkdir output
if not exist Fonts (
echo "Fonts are missing"
goto eof
)
setlocal enabledelayedexpansion
cd Fonts
for %%f in (*tf) do set font_files=!font_files! -attach "%%f"
for %%f in (../*.mkv) do ffmpeg.exe -i "../%%f" -map 0 -c copy %font_files% -metadata:s:t mimetype=application/x-truetype-font "../output/%%f"