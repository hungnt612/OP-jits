import sys
import os
import subprocess
import socket
import getpass
import re

# Getting dir
_top_dir=os.getcwd().split('\\')[-1]
_bash_dir=_top_dir+"/bashScript/"
# sys.path.insert(0,f"{_script_dir}")
from functions import *
print(_bash_dir)

def install_mariadb():
    print("Install mariadb")
    process=subprocess.call(f"{_bash_dir}mariadb_install.sh",shell=True)
    # if(process!=0):
    #     print(f"{bcolors.FAIL}Extute script failed...{bcolors.ENDC}")
    #     quit()
    check_process(process, install_mariadb.__name__ )
    print(f"{bcolors.OKGREEN}Install mariadb sucess"+ f"{bcolors.ENDC}")
    print("Creating necessary database")
    process=subprocess.call(f"{_bash_dir}db_init.sh",shell=True)
    check_process(process, install_mariadb.__name__ )




print(install_mariadb.__name__ )