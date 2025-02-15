# Create love file

import os
import zipfile

def create_love_file(game_directory, output_love_file, love_path):
    # Create the launch script
    batch_script_path = os.path.join(game_directory, "launch_love.bat")
    with open(batch_script_path, "w") as batch_file:
        batch_file.write(f'@echo off\n"{love_path}" "%~dp0"\n')

    # Create the .love file
    with zipfile.ZipFile(output_love_file, "w") as love_zip:
        for root, _, files in os.walk(game_directory):
            for file in files:
                if file != os.path.basename(output_love_file):
                    file_path = os.path.join(root, file)
                    love_zip.write(file_path, os.path.relpath(file_path, game_directory))

    # Clean up the batch script
    os.remove(batch_script_path)

# Configure paths
game_dir = "map_test"
output_love = "WaW_Game.love"
love_exe_path = r"C:\Program Files\LOVE\love.exe"

create_love_file(game_dir, output_love, love_exe_path)
