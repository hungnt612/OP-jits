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

def config_glance(ip_local):
    find_and_replace_config("controller=controller",f"{_bash_dir}glance.sh",f"controller={ip_local}")
    cmd=f"bash {_bash_dir}glance.sh"
    process=subprocess.call(str(cmd), shell=True)
    check_process(process, cmd )
    cmd=" mv /etc/glance/glance-api.conf /etc/glance/glance-api.conf.org"
    process=subprocess.call(str(cmd), shell=True)
    check_process(process, cmd )
    find_and_replace_text("IP_LOCAL",f"{_top_dir}/lib/glance-api.conf",f"{ip_local}")
    process=subprocess.call(f"cat {_top_dir}/lib/glance-api.conf && sleep 10", shell=True)
    cmd=f"cp {_top_dir}/lib/glance-api.conf /etc/glance"
    process=subprocess.call(str(cmd), shell=True)
    check_process(process, cmd )
    cmd="chmod 640 /etc/glance/glance-api.conf"
    process=subprocess.call(str(cmd), shell=True)
    check_process(process, cmd )
    cmd="chown root:glance /etc/glance/glance-api.conf"
    process=subprocess.call(str(cmd), shell=True)
    check_process(process, cmd )
    cmd=""" su -s /bin/bash glance -c "glance-manage db_sync" """
    process=subprocess.call(str(cmd), shell=True)
    check_process(process, cmd )
    cmd="systemctl restart glance-api"
    process=subprocess.call(str(cmd), shell=True)
    check_process(process, cmd )