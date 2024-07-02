import os
import shutil

# This script is made to gather fonts from a shared "fonts" folder for
# each .ass file in each sub-directory. It assumes each subtitle file
# is in a numeric folder (01, 02, ..., 26) and all fonts include the
# font name in the file name. It also assumes a well formatted .ass file
#
# The script will parse each ass file, search for the fonts used in each
# style, search for the styles used in the script, and create a sublist
# of unique used fonts. This list of unique used fonts will be copied
# to the same numeric folder as the subtitle file. It searches for these
# fonts in the "fonts" directory and will copy ALL font files including
# the font name in the file name (which allows for bold/italic variants)
# Note: This can mean unneeded font variants are copied to the folder.
# TODO: Determine which variants are needed from the .ass file.
#
# This can then be used to multiplex the subtitle into an MKV with the
# necessary font attachments and no additional fonts.
# If any fonts are missing it will tell you.
# You can set dry_run below if you want to see what the script will do
# without actually copying any files.
#
# This script isn't particularly optimized since typically an ass file
# will define fewer than 20 styles and contain fewer than 1000 lines.
# If you have large subtitle files with many styles this may be slow.

font_files = os.listdir("fonts")
folder_names = [f"{i:02d}" for i in range(1,27)]
dry_run = True

for folder_name in folder_names:
    for filename in os.listdir(folder_name):
        if not filename.endswith(".ass"):
            continue

        print(f"Parsing {filename}")
        with open(f"{folder_name}/{filename}", "r", encoding='utf-8') as subs:
            file_parts = subs.read().split("[V4+ Styles]")[1].split("[Events]")
            fonts = file_parts[0].strip().split("\n")[1:]
            styles = {font.split(",")[0].split("Style: ")[1]: font.split(",")[1] for font in fonts}
            uniq_fonts = {font.split(",")[1] for font in fonts}
            
            dialog = [line for line in file_parts[1].strip().split("\n")[1:] if "Dialogue:" in line]
            used_styles =  {line.split(",")[3] for line in dialog}
            
            uniq_used_fonts = {font for style, font in styles.items() if style in used_styles}
            if dry_run:
                print(f"Unique used fonts: {sorted(uniq_used_fonts)}")
            
            for font in uniq_used_fonts:
                found = False
                for font_file in font_files:
                    if font.lower() in font_file.lower():
                        if dry_run:
                            print(f"Will copy 'fonts/{font_file}' to '{folder_name}/{font_file}'")
                        else:
                            shutil.copyfile(f"fonts/{font_file}", f"{folder_name}/{font_file}")
                        found = True
                if not found:
                    print(f"Missing: {font}" )
        print()