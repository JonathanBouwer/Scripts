@echo off
rem = """
python -x "%~f0" %*
pause
exit /b %errorlevel%
"""

import os

SUFFIX   = '.mkv'
FIND     = '.'
REPLACE  = ' '

path =  os.getcwd()
filenames = os.listdir(path)

for filename in filenames:
    if filename[-len(SUFFIX):] != SUFFIX:
        print("Skipping {}".format(filename))
        continue
    base_name = filename[:-len(SUFFIX)]
    new_filename = base_name.replace(FIND, REPLACE) + SUFFIX
    old_path = os.path.join(path, filename)
    new_path = os.path.join(path, new_filename)
    print("Renaming {} to {}".format(filename, new_filename))
    os.rename(old_path, new_path)