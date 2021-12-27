#!/usr/bin/env python

import os
import subprocess
import socket
import getpass
import re
from typing import Tuple
from termcolor import colored
# name="/Users/hungnt"
# if os.path.isdir(name):
#     print( name +"is a directory")
#     subprocess.call(["ls","-l",name])
# else:
#     print(name + "is not a directory")

subnet_interface="0.0.0.0/24"
rootpasswd="th61"
hostname_controller="controller"
hostname_compute="compute"
ServerName_controller="%s:80"%hostname_controller
memcache_servers = '%s:11211'%hostname_controller

def checkAllVariable_func():
    print("\n")
    print(colored("Check all variable","red"))
    print("Subnet interface: " + subnet_interface)
    print("root password: " + rootpasswd)
    print("Host name controller: " + hostname_controller)
    print("Host name computer: " + hostname_compute)
    print("Server name controler: " + ServerName_controller )
    print("Memcache servers: " +memcache_servers)
    print("\n")

def checkOSInfo_func():
    print("\n")
    print(colored('Gathering system information\n',"red"))
    uname ="uname"
    uname_arg = '-a'
    print("Gathering system information with %s command:\n" % uname)
    subprocess.call([uname, uname_arg])
    print("\n")

def checkDiskInfo_func():
    print("\n")
    print(colored('Gathering disk information\n',"red"))
    DISKSPACE="df"
    DISKSPACE_ARG="-h"
    print("Gathering diskspace information with the $DISKSPACE command: \n\n")
    subprocess.call([DISKSPACE,DISKSPACE_ARG])
    print("\n")

def listFile_func():
    print("\n")
    print(colored('List all file in folder source',"red"))
    subprocess.call("ls -al",shell=True )
    print("\n")

def checkUser_func():
    # whoami="whoami"
    # user_temp=subprocess.call([whoami])
    # str_user=user_temp
    # user=str(str_user)
    # import socket
    # hostname = socket.gethostname()
    # print(hostname)
    # print(user_temp)
    user=getpass.getuser()
    print(colored('Process are running which user: '+ user,"red"))
    if(user=='root'):
        print(colored("Running by root user","red"))
    else:
        print(colored("Must be running by root user\nEXIT NOW","red"))
        exit()

def mariadbCheck_func():
    command="dpkg -l | awk '/mariadb/ {print }'|wc -l"
    mariadb_status=subprocess.call(command, shell=True)
    # if(mariadb_status==0):
    print("Mariadb not ready, install it now")
        # subprocess.call("dnf module -y install mariadb:10.3", shell=True)
    subprocess.call("chmod +x mariadb_install.sh", shell=True)
    subprocess.call("./mariadb_install.sh", shell=True)
    # if(mariadb_status==1):
    #     print("Mariadb are ready")

def ntpServerCheck_func():
    command="dnf -y install chrony"
    subprocess.call(command,shell=True)
    subprocess.call("echo allow %s >> /etc/chrony.conf" %subnet_interface, shell=True)
    subprocess.call("systemctl enable --now chronyd && firewall-cmd --add-service=ntp --permanent && firewall-cmd --reload", shell=True)

def addOpentackRepo_func():
    command="""dnf -y install centos-release-openstack-victoria && sed -i -e "s/enabled=1/enabled=0/g" /etc/yum.repos.d/CentOS-OpenStack-victoria.repo && dnf --enablerepo=centos-openstack-victoria -y upgrade"""
    # subprocess.call(command, shell=True)
    flag=subprocess.call(command, shell=True)
    if(flag !=0):
        print("Cannot add OP repo, exit now")
        exit()


def replace_line(file_name, line_num, text):
    # lines = open(file_name, 'r').readlines()
    # lines[line_num] = text
    # out = open(file_name, 'w')
    # out.writelines(lines)
    # out.close()
    with open(file_name,'r') as f:
        get_all=f.readlines()
        print(get_all)
    with open(file_name,'w') as f:
        for i,line in enumerate(get_all,1):         ## STARTS THE NUMBERING FROM 1 (by default it begins with 0)    
            if i == line_num:                       ## OVERWRITES line:line_num
                f.writelines("%s\n" %text)
            else:
                f.writelines(line)
    
def add_line(filename, find, insert):
    with open(filename) as in_file:
        old_contents = in_file.readlines()

    with open(filename, 'w') as in_file:
        for line in old_contents:
            in_file.write(line)
            if re.match(r"%s"%find, line):
                in_file.write('%s\n'%insert)

    # def find_append_to_file():
    # """Find and append text in a file."""
    # with open(filename, 'r+') as file:
    #     lines = file.read()

    #     index = repr(lines).find(find) - 1
    #     if index < 0:
    #         raise ValueError("The text was not found in the file!")

    #     len_found = len(find) - 1
    #     old_lines = lines[index + len_found:]

    #     file.seek(index)
    #     file.write(insert)
    #     file.write(old_lines)

def findAndReplace_func(file_name, old, new):
    # Read in the file
    with open(file_name, 'r') as file :
        filedata = file.read()
# Replace the target string
    filedata = filedata.replace(old, new)
# Write the file out again
    with open(file_name, 'w') as file:
        file.write(filedata)

def getRequirements_func():
    mariadbCheck_func()
    ntpServerCheck_func()
    addOpentackRepo_func()
    subprocess.call("yum install epel-release -y", shell=True)
    print("Install RabbitMQ, Memcached.")
    print("enable powertools")
    flag=subprocess.call("dnf --enablerepo=powertools -y install rabbitmq-server memcached", shell=True)
    if(flag != 0 ):
        print("Install Install RabbitMQ, Memcached fail")
        exit()
    print("edit mariadb conf")
    # replace_line("/etc/my.cnf.d/mariadb-server.cnf", 151,"max_connections=500")
    add_line("/etc/my.cnf.d/mariadb-server.cnf", "[mysqld]","max_connections=500")
    replace_line("/etc/sysconfig/memcached", 5, """OPTIONS="-l 0.0.0.0,::" """)
    subprocess.call("systemctl restart mariadb rabbitmq-server memcached", shell=True)
    subprocess.call("systemctl enable mariadb rabbitmq-server memcached", shell=True)
    print("add openstack user")
    subprocess.call("rabbitmqctl add_user openstack password",shell=True)
    subprocess.call("""rabbitmqctl set_permissions openstack ".*" ".*" ".*" """,shell=True)
    print("If SELinux is enabled, change policy.")
    subprocess.call("checkmodule -m -M -o rabbitmqctl.mod rabbitmqctl.te && semodule_package --outfile rabbitmqctl.pp --module rabbitmqctl.mod && semodule -i rabbitmqctl.pp",shell=True)
    print("If Firewalld is running, allow ports for services.")
    subprocess.call("firewall-cmd --add-service={mysql,memcache} --permanent && firewall-cmd --add-port=5672/tcp --permanent &&  firewall-cmd --reload", shell=True)

    
def prepareDB_func():
    print("Prepare database....")
    string="rootpasswd='%s' "%rootpasswd
    print(string)
    replace_line("db_init.sh", 4,string)
    subprocess.call("./db_init.sh", shell=True)

def activeKeyston_func():
    string="export OS_AUTH_URL=http://%s/v3"%hostname_controller
    replace_line("keystonerc",6,string)
    subprocess.call("echo keystonerc > ~/keystonerc",shell=True)
    subprocess.call("chmod 600 ~/keystonerc", shell=True)
    subprocess.call("source ~/keystonerc && echo 'source ~/keystonerc '' >> ~/.bash_profile", shell=True)

def setupKeystone_func():
    print("Install Keystone")
    flag=subprocess.call("dnf --enablerepo=centos-openstack-victoria,epel,powertools -y install openstack-keystone python3-openstackclient httpd mod_ssl python3-mod_wsgi python3-oauth2client", shell=True)
    if(flag!=0):
        print("Install fail")
        exit()
    replace_line("/etc/keystone/keystone.conf",440,memcache_servers)
    connection="connection = mysql+pymysql://keystone:password@%s/keystone "%hostname_controller
    replace_line("/etc/keystone/keystone.conf",615,connection)
    string1="provider = fernet"
    replace_line("/etc/keystone/keystone.conf",2499,string1)
    subprocess.call("su -s /bin/bash keystone -c 'keystone-manage db_sync'",shell=True)
    print('initialize keys')
    subprocess.call("keystone-manage fernet_setup --keystone-user keystone --keystone-group keystone",shell=True)
    subprocess.call("keystone-manage credential_setup --keystone-user keystone --keystone-group keystone",shell=True)
    command="keystone-manage bootstrap --bootstrap-password adminpassword --bootstrap-admin-url http://%s:5000/v3/ --bootstrap-internal-url http://%s:5000/v3/ --bootstrap-public-url http://%s:5000/v3/ --bootstrap-region-id RegionOne "%(hostname_controller,hostname_controller,hostname_controller)
    subprocess.call(command,shell=True)
    print("If SELinux is enabled, change boolean settings.")
    subprocess.call("setsebool -P httpd_use_openstack on && setsebool -P httpd_can_network_connect on && setsebool -P httpd_can_network_connect_db on", shell=True)
    subprocess.call("checkmodule -m -M -o keystone-httpd.mod keystone-httpd.te && semodule_package --outfile keystone-httpd.pp --module keystone-httpd.mod && semodule -i keystone-httpd.pp",shell=True)
    print("If Firewalld is running, allow ports for services.")
    subprocess.call("firewall-cmd --add-port=5000/tcp --permanent && firewall-cmd --reload", shell=True)
    print("Enable settings for Keystone and start Apache httpd.")
    replace_line("/etc/httpd/conf/httpd.conf",98,ServerName_controller)
    subprocess.call("ln -s /usr/share/keystone/wsgi-keystone.conf /etc/httpd/conf.d/", shell=True)
    subprocess.call("systemctl enable --now httpd", shell=True)
    string2="export OS_AUTH_URL=http://%s/v3"%hostname_controller
    replace_line("keystonerc",6,string2)
    subprocess.call("cp keystonerc > /root/keystonerc",shell=True)
    subprocess.call("chmod 600 /root/keystonerc", shell=True)
    print("test")
    subprocess.call("source ~/keystonerc && echo 'source ~/keystonerc '' >> ~/.bash_profile", shell=True)
    print("Create OP Projects.")
    subprocess.call("openstack project create --domain default --description 'Service Project' service",shell=True)
    
def  configureGlance_func():
    activeKeyston_func()
    print("Install and Configure OpenStack Image Service (Glance).")
    print("create [glance] user in [service] project")
    subprocess.call("openstack user create --domain default --project service --password servicepassword glance",shell=True)
    print("add [glance] user in [admin] role")
    subprocess.call("openstack role add --project service --user glance admin", shell=True)
    print("create service entry for [glance]")
    subprocess.call("openstack service create --name glance --description 'OpenStack Image service' image",shell=True)
    print("create endpoint for [glance] (public)")
    subprocess.call("openstack endpoint create --region RegionOne image public http://%s:9292"%hostname_controller, shell=True)
    print("create endpoint for [glance] (internal)")
    subprocess.call("openstack endpoint create --region RegionOne image internal http://%s:9292"%hostname_controller,shell=True)
    print("create endpoint for [glance] (admin)")
    subprocess.call("openstack endpoint create --region RegionOne image admin http://%s:9292"%hostname_controller, shell=True)
    print("Install Glance.")
    print("install from Victoria, EPEL, powertools")
    subprocess.call("dnf --enablerepo=centos-openstack-victoria,powertools,epel -y install openstack-glance", shell=True)
    print("Configure Glance.")
    subprocess.call("mv /etc/glance/glance-api.conf /etc/glance/glance-api.conf.org", shell=True)
    findAndReplace_func("glance-api.conf","CONTROLER_HOST",hostname_controller)
    subprocess.call("chmod 640 /etc/glance/glance-api.conf && chown root:glance /etc/glance/glance-api.conf && su -s /bin/bash glance -c 'glance-manage db_sync'", shell=True)
    subprocess.call("systemctl enable --now openstack-glance-api && echo 'If SELinux is enabled, change boolean settings.' && setsebool -P glance_api_can_network on",shell=True)
    subprocess.call("checkmodule -m -M -o glanceapi.mod glanceapi.te && semodule_package --outfile glanceapi.pp --module glanceapi.mod && semodule -i glanceapi.pp", shell=True)
    print("If Firewalld is running, allow ports for services.")
    subprocess.call("firewall-cmd --add-port=9292/tcp --permanent && firewall-cmd --reload",shell=True)

def configureNova_func():
    activeKeyston_func()
    print("Create [nova] user in [service] project")
    subprocess.call("openstack user create --domain default --project service --password servicepassword nova", shell=True)
    print("Add [nova] user in [admin] role")
    subprocess.call("", shell=True)
    
    


subprocess.call("", shell=True)

def __main():
    # checkOSInfo_func()
    # checkDiskInfo_func()
    # listFile_func()
    # checkAllVariable_func()
    # checkUser_func()
    # getRequirements_func()
    # prepareDB_func()
    setupKeystone_func()
    # listFile_func()
    # checkUser_func()
    # subprocess.call("ls -al",shell=True )
    # mariadbCheck_func()
    # getRequirements_func()
    # replace_line('/Users/hungnt/project/bash/op/py/dmhieu', 3,"condihieu3" )
    # add_line('/Users/hungnt/project/bash/op/py/dmhieu', "abc" ,"condihieu2.7")
    # prepareDB_func()
    # print(command)
    # print("openstack endpoint create --region RegionOne image public http://%s:9292"%hostname_controller)
    # findAndReplace_func("glance-api.conf","10.0.0.30","CONTROLER_HOST")
    print('SETUP COMPLETE')

if __name__ == "__main__":
    __main()