@echo off

rem This script will loop through all cbz files in a directory and
rem run 7z.exe to extract them into folders.

for %%f in (*.cbz) do (
echo %%~nf
mkdir "%%~nf"
"C:\Program Files\7-Zip\7z.exe" e "%%f" -o"%%~nf" > nul
)
pause