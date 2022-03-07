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
# print(_bash_dir)

def install_package():
    print("Install package requiment")
    process=subprocess.call(f"{_bash_dir}package.sh",shell=True)
    # if(process!=0):
    #     print(f"{bcolors.FAIL}Extute script failed...{bcolors.ENDC}")
    #     quit()
    check_process(process, install_package.__name__ )
    print("Setup memcached")
    process=subprocess.call("rabbitmqctl add_user openstack password", shell=True)
    check_process(process, "rabbitmqctl add_user openstack password" )
    process=subprocess.call("rabbitmqctl set_permissions openstack '.*' '.*' '.*' ", shell=True)
    check_process(process, """Setting permissions for user "openstack" in vhost "/" ... """ )
    find_and_replace_config("-l 127.0.0.1","/etc/memcached.conf","-l 0.0.0.0")
    process=subprocess.call("systemctl restart rabbitmq-server memcached",shell=True)
    check_process(process, "systemctl restart rabbitmq-server memcached" )



