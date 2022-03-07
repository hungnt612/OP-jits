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

def config_keystone(ip_local):
    # find_and_replace_config("#memcache_servers = localhost:11211","/etc/keystone/keystone.conf",f"memcache_servers = {ip_local}:11211")
    # find_and_replace_config("connection = sqlite:////var/lib/keystone/keystone.db","/etc/keystone/keystone.conf",f"connection = mysql+pymysql://keystone:password@{ip_local}/keystone")
    # find_and_replace_config("provider = fernet","/etc/keystone/keystone.conf",f"provider = fernet")
    # cmd=""" su -s /bin/bash keystone -c "keystone-manage db_sync" """
    # process=subprocess.call(str(cmd), shell=True)
    # check_process(process, cmd )
    cmd= "keystone-manage fernet_setup --keystone-user keystone --keystone-group keystone"
    process=subprocess.call(str(cmd), shell=True)
    check_process(process, cmd )
    cmd= "keystone-manage credential_setup --keystone-user keystone --keystone-group keystone"
    process=subprocess.call(str(cmd), shell=True)
    check_process(process, cmd )
    cmd=f"keystone-manage bootstrap --bootstrap-password adminpassword --bootstrap-admin-url http://{ip_local}:5000/v3/ --bootstrap-internal-url http://{ip_local}:5000/v3/ --bootstrap-public-url http://{ip_local}:5000/v3/ --bootstrap-region-id RegionOne"
    process=subprocess.call(str(cmd), shell=True)
    check_process(process, cmd )
    cmd=f"cp {_top_dir}/lib/keystonerc /root"
    process=subprocess.call(str(cmd), shell=True)
    check_process(process, cmd )
    find_and_replace_config("export OS_AUTH_URL=","/root/keystonerc",f"export OS_AUTH_URL=http://{ip_local}:5000/v3")
    print(""" create [service] project """)
    cmd="""openstack project create --domain default --description "Service Project" service"""
    process=subprocess.call(str(cmd), shell=True)
    check_process(process, cmd )