#!/bin/bash
source ../module/echo.sh
source VARIABLE.sh

echo_job_detail "Install and Configure OpenStack Block Storage (Cinder)."
echo_noti "	Add a User or Endpoint for Cinder to Keystone on Control Node."
echo_noti " create [cinder] user in [service] project"
openstack user create --domain default --project service --password servicepassword cinder
echo_noti " add [cinder] user in [admin] role"
openstack role add --project service --user cinder admin
echo_noti "create service entry for [cinder]"
openstack service create --name cinderv3 --description "OpenStack Block Storage" volumev3
echo_noti "create endpoint for [cinder] (public)"
openstack endpoint create --region RegionOne volumev3 public http://$controller:8776/v3/%\(tenant_id\)s
echo_noti "create endpoint for [cinder] (internal)"
openstack endpoint create --region RegionOne volumev3 internal http://$controller:8776/v3/%\(tenant_id\)s
echo_noti "create endpoint for [cinder] (admin)"
openstack endpoint create --region RegionOne volumev3 admin http://$controller:8776/v3/%\(tenant_id\)s
echo_noti "	Install Cinder Service."
dnf --enablerepo=centos-openstack-victoria,powertools,epel -y install openstack-cinder
echo_noti "Create config file /etc/cinder/cinder.conf"
mv /etc/cinder/cinder.conf /etc/cinder/cinder.conf.org
cat ../config_file/cinder.conf > /etc/cinder/cinder.conf
chmod 640 /etc/cinder/cinder.conf
chgrp cinder /etc/cinder/cinder.conf
su -s /bin/bash cinder -c "cinder-manage db sync"
systemctl enable --now openstack-cinder-api openstack-cinder-scheduler
# echo "export OS_VOLUME_API_VERSION=3" >> ~/keystonerc
# source ~/keystonerc
openstack volume service list
echo_noti "	SELinux is enabled, change policy like follows."
dnf --enablerepo=centos-openstack-victoria -y install openstack-selinux
echo_noti "	If Firewalld is running, allow service ports."
firewall-cmd --add-port=8776/tcp --permanent
firewall-cmd --reload
