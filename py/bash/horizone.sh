#!/bin/bash
source ../module/echo.sh
source VARIABLE.sh

echo_job_detail "Add User accounts in keystone who can use Openstack System."
echo_job_detail "Configure OpenStack Dashboard Service (Horizon) to control OpenStack on Web GUI."
sleep 3
echo_noti "add a project with name Hiroshima"
openstack project create --domain default --description "Hiroshima Project" hiroshima
echo_noti "add a user"
openstack user create --domain default --project hiroshima --password userpassword serverworld
echo_noti "add a role"
openstack role create CloudUser
echo_noti "add user to the role"
openstack role add --project hiroshima --user serverworld CloudUser
echo_noti "add some [flavor]"
openstack flavor create --id 0 --vcpus 2 --ram 2048 --disk 10 m1.small
openstack flavor create --id 1 --vcpus 4 --ram 4096 --disk 40 m2.small
openstack flavor create --id 2 --vcpus 4 --ram 8192 --disk 40 m3.small
openstack flavor create --id 3 --vcpus 4 --ram 8192 --disk 80 m4.small
openstack flavor create --id 4 --vcpus 8 --ram 16384 --disk 80 m5.small

echo_noti "Install Horizon."
dnf --enablerepo=centos-openstack-victoria,powertools,epel -y install openstack-dashboard
echo_noti "Modify /etc/openstack-dashboard/local_settings"
# python3 ../module/find_and_replace.py "/etc/openstack-dashboard/local_settings" "ALLOWED_HOSTS = ['horizon.example.com', 'localhost']" "ALLOWED_HOSTS = ['*', ]"
# rm /etc/openstack-dashboard/local_settings
cat ../config_file/local_settings_horizone > /etc/openstack-dashboard/local_settings
echo_noti "Modify /etc/httpd/conf.d/openstack-dashboard.conf"
python3 ../module/add_text_to_line.py "/etc/httpd/conf.d/openstack-dashboard.conf" "WSGISocketPrefix run/wsgi" "WSGIApplicationGroup %{GLOBAL}"
echo_noti "Restarting httpd"
systemctl restart httpd
echo_noti "allow common users to access to instances details or console on the Dashboard web"
# python3 ../module/add_text_to_line.py "/etc/nova/policy.json" "{" """ "os_compute_api:os-extended-server-attributes": "rule:admin_or_owner", """
systemctl restart openstack-nova-api
echo_noti "	If SELinux is enabled, change policy."
setsebool -P httpd_can_network_connect on
echo_noti "	If Firewalld is running, allow services."
firewall-cmd --add-service={http,https} --permanent
firewall-cmd --reload
echo_noti "Setup Horizone finish"