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

def config_nova(ip_local):
    find_and_replace_config("controller =",f"{_bash_dir}nova.sh",f"controller={ip_local}")
    cmd=f"bash {_bash_dir}nova.sh"
    process=subprocess.call(str(cmd), shell=True)
    check_process(process, cmd )
    cmd="mv /etc/nova/nova.conf /etc/nova/nova.conf.org"
    process=subprocess.call(str(cmd), shell=True)
    check_process(process, cmd )
    find_and_replace_text("IP_LOCAL",f"{_top_dir}/lib/nova.conf",f"{ip_local}")
    subprocess.call(f" cat {_top_dir}/lib/nova.conf && sleep 10", shell=True)
    cmd=f"cp {_top_dir}/lib/nova.conf /etc/nova"
    process=subprocess.call(str(cmd), shell=True)
    check_process(process, cmd )
    cmd="chmod 640 /etc/nova/nova.conf"
    process=subprocess.call(str(cmd), shell=True)
    check_process(process, cmd )
    cmd="chgrp nova /etc/nova/nova.conf"
    process=subprocess.call(str(cmd), shell=True)
    check_process(process, cmd )
    cmd="mv /etc/placement/placement.conf /etc/placement/placement.conf.org"
    find_and_replace_text("IP_LOCAL",f"{_top_dir}/lib/placement.conf",f"{ip_local}")
    cmd=f"cp {_top_dir}/lib/placement.conf /etc/placement"
    process=subprocess.call(str(cmd), shell=True)
    check_process(process, cmd )
    cmd="chmod 640 /etc/placement/placement.conf"
    process=subprocess.call(str(cmd), shell=True)
    check_process(process, cmd )
    cmd="chgrp placement /etc/placement/placement.conf"
    process=subprocess.call(str(cmd), shell=True)
    check_process(process, cmd )
    cmd="""su -s /bin/bash placement -c "placement-manage db sync" """
    process=subprocess.call(str(cmd), shell=True)
    check_process(process, cmd )
    cmd="""su -s /bin/bash nova -c "nova-manage api_db sync" """
    process=subprocess.call(str(cmd), shell=True)
    check_process(process, cmd )
    cmd="""su -s /bin/bash nova -c "nova-manage cell_v2 map_cell0" """
    process=subprocess.call(str(cmd), shell=True)
    check_process(process, cmd )
    cmd=""" su -s /bin/bash nova -c "nova-manage db sync" """
    process=subprocess.call(str(cmd), shell=True)
    check_process(process, cmd )
    cmd=""" su -s /bin/bash nova -c "nova-manage cell_v2 create_cell --name cell1" """
    process=subprocess.call(str(cmd), shell=True)
    check_process(process, cmd )
    cmd="systemctl restart apache2"
    process=subprocess.call(str(cmd), shell=True)
    check_process(process, cmd )
    cmd="for service in api conductor scheduler novncproxy; do systemctl restart nova-$service; done"
    process=subprocess.call(str(cmd), shell=True)
    check_process(process, cmd )
    cmd="openstack compute service list"
    process=subprocess.call(str(cmd), shell=True)
    check_process(process, cmd )
    cmd="systemctl restart nova-compute"
    process=subprocess.call(str(cmd), shell=True)
    check_process(process, cmd )
    cmd=""" su -s /bin/bash nova -c "nova-manage cell_v2 discover_hosts" """
    process=subprocess.call(str(cmd), shell=True)
    check_process(process, cmd )
    cmd="openstack compute service list"
    process=subprocess.call(str(cmd), shell=True)
    check_process(process, cmd )