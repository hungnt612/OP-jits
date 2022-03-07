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
# phrase=sys.argv[1]
# filename=sys.argv[2]
# newPhrase=sys.argv[3]

# def line_num_for_phrase_in_file(phrase, filename, newPhrase):
#     with open(filename,'r') as f:
#         for (i, line) in enumerate(f):
#             if phrase in line:
#                 print("Found in line "+i)
#                 return i
#     return -1

class bcolors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKCYAN = '\033[96m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'

def find_and_replace_config(phrase, filename, newPhrase):
    flag=None
    with open(filename,'r') as f:
        for (i, line) in enumerate(f):
            if phrase in line:
                line_number=i+1
                print(f"{bcolors.OKGREEN}Found in line " + str(line_number)+ f"{bcolors.ENDC}")
                # print(f"{bcolors.ENDC}Found in line "+line + f"{bcolors.ENDC}")
                # return line
                flag=line_number
                # print(line_number)
                with open(filename,'r') as f:
                    get_all=f.readlines()
                    # print(get_all)
                with open(filename,'w') as f:
                    for i,line in enumerate(get_all,1):         ## STARTS THE NUMBERING FROM 1 (by default it begins with 0)    
                        if i == line_number:                       ## OVERWRITES line:line_num
                            f.writelines("%s\n" %newPhrase)
                        else:
                            f.writelines(line)
        if(flag==None):
            print("Not found " + phrase + " in " + filename)
            print("Please check. Exit now !!!")
    return -1

def get_ip_address():
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    s.connect(("8.8.8.8", 80))
    _ip_local_address=s.getsockname()[0]
    # print(f"{bcolors.OKGREEN}Your IP address is: " + s.getsockname()[0] + f"{bcolors.ENDC}")
    s.close()
    return _ip_local_address

def check_process(process,name):
    if(process!=0):
    # print("Extute script failed...")
        print(f"{bcolors.FAIL}Extute script failed in {name}...{bcolors.ENDC}")
        quit()
    else:
        print(f"{bcolors.OKGREEN}{name} Success...{bcolors.ENDC}")

def find_and_replace_text(phrase, filename, newPhrase):
    # Read in the file
    with open(filename, 'r') as file :
        filedata = file.read()
# Replace the target string
    filedata = filedata.replace(phrase, newPhrase)
# Write the file out again
    with open(filename, 'w') as file:
        file.write(filedata)


# def __main():
#     find_and_replace_text("hungnt","/Users/hungnt/project/OP-jits/value.yaml","dmht")

# if __name__ == "__main__":
#     __main()