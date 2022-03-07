import sys
import os
import subprocess
import socket
import getpass
import re
from typing import Tuple
# prints python_script.py
# print(sys.argv[1]) # prints var1
# print(sys.argv[2]) # prints var2
print(sys.argv[3])

_fileName=sys.argv[1]
_line=sys.argv[2]
_insert=sys.argv[3]

def add_line(filename, find, insert):
    with open(filename) as in_file:
        old_contents = in_file.readlines()

    with open(filename, 'w') as in_file:
        for line in old_contents:
            in_file.write(line)
            if re.match(r"%s"%find, line):
                in_file.write('%s\n'%insert)

    # def find_append_to_file():
    # """Find and append text in a file."""
    # with open(filename, 'r+') as file:
    #     lines = file.read()

    #     index = repr(lines).find(find) - 1
    #     if index < 0:
    #         raise ValueError("The text was not found in the file!")

    #     len_found = len(find) - 1
    #     old_lines = lines[index + len_found:]

    #     file.seek(index)
    #     file.write(insert)
    #     file.write(old_lines)
    
def __main():
    add_line(_fileName, _line, _insert)

if __name__ == "__main__":
    __main()