import sys
import os
import subprocess
import socket
import getpass
import re

# Getting dir
_top_dir=os.getcwd().split('\\')[-1]
_script_dir=_top_dir + "/lib"
# adding folder lib to the system path
sys.path.insert(0,f"{_script_dir}")
from functions import *
from mariadb import *
from getPackages import *
from keystone import *
from glance import *
from nova import *
_bash_dir=_script_dir+"/bashScript/"

#GLOBAL_VARIABLE 
_ip_local_address=get_ip_address()
subnet_interface="0.0.0.0/24"
rootpasswd="admin"
hostname_controller="controller"
# hostname_compute="compute"

#SHOW INFORMATION 
print(f"{bcolors.OKCYAN}Running script in: " + _top_dir + f"{bcolors.ENDC}")
print(f"{bcolors.OKCYAN}Importing module from: {_script_dir} {bcolors.ENDC}")
print(f"{bcolors.OKGREEN}Your IP address is: " + _ip_local_address + f"{bcolors.ENDC}")
subprocess.call("sleep 5 && echo 'Starting now....'",shell=True)


subprocess.call(f"chmod +x {_bash_dir}*",shell=True)
install_package()
config_keystone(_ip_local_address)
