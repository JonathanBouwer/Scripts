@echo off
rem = """
python -x "%~f0" %*
pause
exit /b %errorlevel%
"""

import os

def sort_files():
    folders = {}
    for dirpath, dirnames, filenames in os.walk(os.getcwd()):
        folder_name = dirpath[len(os.getcwd()) + 1:]
        if '\\' in folder_name:
            continue
        folders[folder_name] = [file for file in filenames if file.endswith('.mkv')]

    videos = folders.pop('')
    for folder_name, folder_contents in folders.items():
        for file_name in videos:
            if folder_name not in file_name:
                continue
            if file_name in folder_contents:
                print(f'"{folder_name}/{file_name}" already exists! Skipping')
                continue
            print(f'Moving "{file_name}" to "{folder_name}"')
            os.rename(file_name, f'{folder_name}/{file_name}')

if __name__=='__main__':
    sort_files()
