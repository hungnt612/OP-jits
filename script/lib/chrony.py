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

# Install Chrony and Configure NTP server for time adjustment. NTP uses 123/UDP.
def install_chrony():
    process=subprocess.call("sudo apt -y install chrony",shell=True)