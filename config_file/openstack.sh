#!/bin/bash
#print date time on screen
echo "`date`"

IP_SUBNET=""
CONTROLLER_IP="unknown"
COMPUTE_IP="unknown"
rootpasswd="th61"

echo "Add Repository of Openstack Victoria and also Upgrade CentOS System."
sleep 2
dnf -y install centos-release-openstack-victoria
sed -i -e "s/enabled=1/enabled=0/g" /etc/yum.repos.d/CentOS-OpenStack-victoria.repo
dnf --enablerepo=centos-openstack-victoria -y upgrade
yum -y install epel-release

dnf --enablerepo=powertools -y install rabbitmq-server memcached
echo "config mariadb"
rm -rf /etc/my.cnf.d/mariadb-server.cnf
cp mariadb-server.cnf /etc/my.cnf.d/mariadb-server.cnf
echo "config memcached"
rm -rf /etc/sysconfig/memcached
cp memcached /etc/sysconfig/memcached
systemctl restart mariadb rabbitmq-server memcached
systemctl enable mariadb rabbitmq-server memcached

echo "add openstack user"
echo "set any password you like for [password]"
sleep 2
rabbitmqctl add_user openstack password
rabbitmqctl set_permissions openstack ".*" ".*" ".*"

echo "change policy SELinux"
sleep 1
checkmodule -m -M -o rabbitmqctl.mod rabbitmqctl.te
semodule_package --outfile rabbitmqctl.pp --module rabbitmqctl.mod
semodule -i rabbitmqctl.pp

echo "allow ports for services"
firewall-cmd --add-service={mysql,memcache} --permanent
firewall-cmd --add-port=5672/tcp --permanent
firewall-cmd --reload

echo "CONFIG KEYSTONEEEEEEEEEEEEEEE"
echo "Add a User and Database on MariaDB for Keystone."
mysql -uroot -p${rootpasswd} -e "create database keystone;"
mysql -uroot -p${rootpasswd} -e "grant all privileges on keystone.* to keystone@'localhost' identified by 'password';"
mysql -uroot -p${rootpasswd} -e "grant all privileges on keystone.* to keystone@'%' identified by 'password';"
mysql -uroot -p${rootpasswd} -e "flush privileges;"

echo "Install Keystone. install from Victoria, EPEL, powertools"
dnf --enablerepo=centos-openstack-victoria,epel,powertools -y install openstack-keystone python3-openstackclient httpd mod_ssl python3-mod_wsgi python3-oauth2client


cat keystone.conf  | sed 's:MEMCACHED_SERVERS:'"${CONTROLLER_IP}:11211:" | sed 's:CONNECTION_DB:'"mysql+pymysql://keystone:password@${CONTROLLER_IP}/keystone:" > /etc/keystone/keystone.conf
# sed -i "s/#memcache_servers =.*/memcache_servers = ${CONTROLLER_IP}:11211/g" /etc/keystone/keystone.conf
# sed -i "s/connection =.*/connection = mysql+pymysql://keystone:password@${CONTROLLER_IP}/keystone/g" /etc/keystone/keystone.conf
echo "provider = fernet" >> /etc/keystone/keystone.conf

su -s /bin/bash keystone -c "keystone-manage db_sync"

echo "initialize keys"
keystone-manage fernet_setup --keystone-user keystone --keystone-group keystone
keystone-manage credential_setup --keystone-user keystone --keystone-group keystone
export controller=${CONTROLLER_IP}
keystone-manage bootstrap --bootstrap-password adminpassword --bootstrap-admin-url http://$controller:5000/v3/ --bootstrap-internal-url http://$controller:5000/v3/ --bootstrap-public-url http://$controller:5000/v3/ --bootstrap-region-id RegionOne

echo "If SELinux is enabled, change boolean settings."
setsebool -P httpd_use_openstack on
setsebool -P httpd_can_network_connect on
setsebool -P httpd_can_network_connect_db on
checkmodule -m -M -o keystone-httpd.mod keystone-httpd.te
semodule_package --outfile keystone-httpd.pp --module keystone-httpd.mod
semodule -i keystone-httpd.pp

echo "	If Firewalld is running, allow ports for services."
firewall-cmd --add-port=5000/tcp --permanent
firewall-cmd --reload

echo "Enable settings for Keystone and start Apache httpd."
sed -i "s/ServerName .*/ServerName  controller:80/g" /etc/httpd/conf/httpd.conf
ln -s /usr/share/keystone/wsgi-keystone.conf /etc/httpd/conf.d/
systemctl enable --now httpd

echo "	Create and Load environment variables file."
sed -i "s/export OS_AUTH_URL=.*/export OS_AUTH_URL=${CONTROLLER_IP}/v3/g" keystonerc
chmod 600 keystonerc
source keystonerc
echo "source keystonerc " >> ~/.bash_profile

echo "create [service] project"
openstack project create --domain default --description "Service Project" service
echo "check project"
openstack project list

echo "Configure Glanceeeeeeeee"
echo "create [glance] user in [service] project"
openstack user create --domain default --project service --password servicepassword glance
echo "add [glance] user in [admin] role"
openstack role add --project service --user glance admin
echo "create service entry for [glance]"
openstack service create --name glance --description "OpenStack Image service" image
export controller=${CONTROLLER_IP}
echo " create endpoint for [glance] (public)"
openstack endpoint create --region RegionOne image public http://$controller:9292
echo "create endpoint for [glance] (internal)"
openstack endpoint create --region RegionOne image internal http://$controller:9292
echo "create endpoint for [glance] (admin)"
openstack endpoint create --region RegionOne image admin http://$controller:9292
echo "	Add a User and Database on MariaDB for Glance."
mysql -uroot -p${rootpasswd} -e "create database glance; "
mysql -uroot -p${rootpasswd} -e "grant all privileges on glance.* to glance@'localhost' identified by 'password'; "
mysql -uroot -p${rootpasswd} -e "grant all privileges on glance.* to glance@'%' identified by 'password'; "
mysql -uroot -p${rootpasswd} -e "flush privileges; "

echo "Install Glance. install from Victoria, EPEL, powertools"
dnf --enablerepo=centos-openstack-victoria,powertools,epel -y install openstack-glance
echo "Configure Glance."


cat glance-api.conf | sed 's:CONNECTION_DB:'"mysql+pymysql://glance:password@${CONTROLLER_IP}/glance:" | sed 's:AUTHENTICATE_URI:'"http://${CONTROLLER_IP}:5000:" | sed 's:AUTH_URL:'"http://${CONTROLLER_IP}:5000:" | sed 's:MEMCACHED_SERVERS:'"${CONTROLLER_IP}:11211:" > /etc/glance/glance-api.conf