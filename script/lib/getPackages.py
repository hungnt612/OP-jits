import sys
import os
import subprocess
import socket
import getpass
import re

# Getting dir
_top_dir=os.getcwd().split('\\')[-1]
_bash_dir=_top_dir+"/lib/bashScript/"
# sys.path.insert(0,f"{_script_dir}")
from functions import *
print(_bash_dir)

def install_package():
    print("Install package requiment")
    process=subprocess.call(f"{_bash_dir}package.sh",shell=True)
    # if(process!=0):
    #     print(f"{bcolors.FAIL}Extute script failed...{bcolors.ENDC}")
    #     quit()
    check_process(process, install_package.__name__ )



