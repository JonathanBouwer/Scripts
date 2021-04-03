@echo off

rem Thius script will loop through a directory extract track 0 and 1 subtitles
rem (assumed to be .ass subs), Change the font from Arial to Open Sans Semibold
rem then remux the video to have necessary attached fonts.
rem Output is saved in a new directory called output

echo import sys >> swap_subs.py
echo import re >> swap_subs.py
echo.>> swap_subs.py
echo FIND = "Style: Default,Arial,55" >> swap_subs.py
echo REPLACE = "Style: Default,Open Sans Semibold,75" >> swap_subs.py
echo.>> swap_subs.py
echo def main(): >> swap_subs.py
echo     filename = sys.argv[1] >> swap_subs.py
echo     with open(filename, "r+") as f: >> swap_subs.py
echo         content = f.read() >> swap_subs.py
echo         new_content = re.sub(FIND, REPLACE, content, 1) >> swap_subs.py
echo         f.seek(0) >> swap_subs.py
echo         f.write(new_content) >> swap_subs.py
echo.>> swap_subs.py
echo main()  >> swap_subs.py

mkdir output
for %%f in (*.mkv) do (
	ffmpeg -i "%%f" -map 0:s:0 "%%~nf0.ass"
	ffmpeg -i "%%f" -map 0:s:1 "%%~nf1.ass"
	python swap_subs.py "%%~nf0.ass"
	python swap_subs.py "%%~nf1.ass"
	ffmpeg -i "%%f" -i "%%~nf1.ass" -i "%%~nf0.ass" -map 0:v:0 -map 0:a:1 -map 0:a:0 -map 1:s:0 -map 2:s:1 -attach OpenSans-Semibold.ttf -metadata:s:3 mimetype=application/x-truetype-font -map 0:t -c copy -disposition:a:0 default -disposition:a:1 none -disposition:s:0 default -disposition:s:1 none "output/%%f"
	ffmpeg -i "%%f" -i "%%~nf1.ass" -i "%%~nf0.ass" -map 0:v:0 -map 0:a:1 -map 0:a:0 -map 1:s:0 -map 2:s:0 -metadata:s:3 language=eng -metadata:s:3 title="English Subtitles" -metadata:s:4 language=eng -metadata:s:4 title="English Lyrics/Signs" -attach OpenSans-Semibold.ttf -metadata:s:t mimetype=application/x-truetype-font -map 0:t -c copy -disposition:a:0 default -disposition:a:1 none -disposition:s:0 default -disposition:s:1 none "output/%%f"
	del "%%~nf0.ass"
	del "%%~nf1.ass"
)

del swap_subs.py

pause