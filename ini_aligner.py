"""Align all key/value pairs in a given INI file"""

# Set file path here
file_path = ''

file_lines = open(file_path, 'r', encoding='UTF-8').readlines()
max_key_length = 0
kv_line_numbers = []
new_lines = file_lines

# Find all k/v lines and add the line number to list
for idx, line in enumerate(file_lines):
    if line.find('=') != -1:

        kv_line_numbers.append(idx)
        line = line.split('=')

        key_length = len(line[0].strip())

        if key_length > max_key_length:
            max_key_length = key_length

# Align every k/v line
for line in kv_line_numbers:
    line_content = new_lines[line].split('=')

    key_length = len(line_content[0].strip())

    numspaces = max_key_length - key_length

    new_lines[line] = line_content[0] + (' ' * numspaces) + '= ' + line_content[1]

# Write new file contents
with open(file_path, 'w', encoding='UTF-8') as file:
    file.writelines(new_lines)
