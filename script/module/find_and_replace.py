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

def findAndReplace_func(file_name, old, new):
    # Read in the file
    with open(file_name, 'r') as file :
        filedata = file.read()
# Replace the target string
    filedata = filedata.replace(old, new)
# Write the file out again
    with open(file_name, 'w') as file:
        file.write(filedata)

def __main():
    findAndReplace_func(_fileName, _line, _insert)

if __name__ == "__main__":
    __main()