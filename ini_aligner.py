"""Align all key/value pairs in a given INI file"""

from copy import deepcopy
from os.path import exists
import sys

if len(sys.argv) <= 1:
    print("Please specify a file path.")
    print(f"Example: {sys.argv[0]} /path/to/file.ini")
    sys.exit(1)

if not exists(sys.argv[1]):
    print("Path does not exist.")
    sys.exit(1)

FILE_PATH = sys.argv[1]
MAX_KEY_LENGTH = 0
kv_line_numbers = []
file_lines = open(FILE_PATH, "r", encoding="UTF-8").readlines()
new_lines = deepcopy(file_lines)

# Find all k/v lines and add the line number to list
for idx, line in enumerate(file_lines):
    if line.find("=") != -1:

        kv_line_numbers.append(idx)
        line = line.split("=")

        key_length = len(line[0].strip())

        if key_length > MAX_KEY_LENGTH:
            MAX_KEY_LENGTH = key_length

# Align every k/v line
for line in kv_line_numbers:
    line_content = new_lines[line].split("=")

    key_length = len(line_content[0].strip())

    numspaces = MAX_KEY_LENGTH - key_length

    new_lines[line] = (
        line_content[0].strip()
        + (" " * numspaces)
        + "= " + line_content[1].strip()
        + "\n"
    )

if new_lines != file_lines:
    # Write new file contents
    with open(FILE_PATH, "w", encoding="UTF-8") as file:
        file.writelines(new_lines)

    print(f"Aligned {FILE_PATH}")
else:
    print("No changes made; file is already aligned.")
