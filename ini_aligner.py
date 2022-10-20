"""Align all key/value pairs in a given INI file"""

from copy import deepcopy
from os.path import exists
import sys

# Set file path here
if len(sys.argv) <= 1:
    print("Please specify a file path.")
    print(f"Example: {sys.argv[0]} /path/to/file.ini")
    sys.exit(1)

if not exists(sys.argv[1]):
    print("Path does not exist.")
    sys.exit(1)

file_path = sys.argv[1]
file_lines = open(file_path, "r", encoding="UTF-8").readlines()
max_key_length = 0
kv_line_numbers = []
new_lines = deepcopy(file_lines)

# Find all k/v lines and add the line number to list
for idx, line in enumerate(file_lines):
    if line.find("=") != -1:

        kv_line_numbers.append(idx)
        line = line.split("=")

        key_length = len(line[0].strip())

        if key_length > max_key_length:
            max_key_length = key_length

# Align every k/v line
for line in kv_line_numbers:
    line_content = new_lines[line].split("=")

    key_length = len(line_content[0].strip())

    numspaces = max_key_length - key_length

    new_lines[line] = line_content[0].strip() + (" " * numspaces) + "= " + line_content[1].strip() + "\n"

if new_lines != file_lines:
    # Write new file contents
    with open(file_path, "w", encoding="UTF-8") as file:
        file.writelines(new_lines)

    print(f"Aligned {file_path}")
else:
    print("No changes made; file is already aligned.")
