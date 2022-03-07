#!/bin/bash
# source module/echo.sh
#print date time on screen
echo "`date`"

echo "rabbitmq"
sudo apt install -y rabbitmq-server memcached python3-pymysql
echo "keystone && glance"
sudo apt -y install keystone python3-openstackclient apache2 libapache2-mod-wsgi-py3 python3-oauth2client glance
echo "kvm"
sudo apt -y install qemu-kvm libvirt-daemon-system libvirt-daemon virtinst bridge-utils libosinfo-bin libguestfs-tools virt-top
# sudo apt -y install ssh cloud-init linux-virtual pollinate
echo "nova"
sudo apt -y install nova-api nova-conductor nova-scheduler nova-novncproxy placement-api python3-novaclient nova-compute nova-compute-kvm
echo "neutron"
sudo apt -y install neutron-server neutron-plugin-ml2 neutron-linuxbridge-agent neutron-l3-agent neutron-dhcp-agent neutron-metadata-agent python3-neutronclient
echo "Horizon"
sudo apt -y install openstack-dashboard
echo "OpenStack Load Balancing as a Service (Octavia)"
snap install octavia-diskimage-retrofit --beta --devmode
echo "cinder"
sudo apt -y install cinder-api cinder-scheduler python3-cinderclient
