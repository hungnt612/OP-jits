#!/bin/bash
#print date time on screen
echo "`date`"
rootpasswd='th61' 

mysql -uroot -p${rootpasswd} -e

echo "CONFIG KEYSTONEEEEEEEEEEEEEEE"
echo "Add a User and Database on MariaDB for Keystone."
mysql -uroot -p${rootpasswd} -e "create database keystone;"
mysql -uroot -p${rootpasswd} -e "grant all privileges on keystone.* to keystone@'localhost' identified by 'password';"
mysql -uroot -p${rootpasswd} -e "grant all privileges on keystone.* to keystone@'%' identified by 'password';"
mysql -uroot -p${rootpasswd} -e "flush privileges;"
echo "Add a User and Database on MariaDB for Glance."
mysql -uroot -p${rootpasswd} -e "create database glance;"
mysql -uroot -p${rootpasswd} -e "grant all privileges on glance.* to glance@'localhost' identified by 'password'; "
mysql -uroot -p${rootpasswd} -e "grant all privileges on glance.* to glance@'%' identified by 'password'; "
mysql -uroot -p${rootpasswd} -e "flush privileges; "
echo "Add a User and Database on MariaDB for Nova."
mysql -uroot -p${rootpasswd} -e "create database nova; "
mysql -uroot -p${rootpasswd} -e "grant all privileges on nova.* to nova@'localhost' identified by 'password'; "
mysql -uroot -p${rootpasswd} -e "grant all privileges on nova.* to nova@'%' identified by 'password'; "
mysql -uroot -p${rootpasswd} -e "create database nova_api; "
mysql -uroot -p${rootpasswd} -e "grant all privileges on nova_api.* to nova@'localhost' identified by 'password'; "
mysql -uroot -p${rootpasswd} -e "grant all privileges on nova_api.* to nova@'%' identified by 'password'; "
mysql -uroot -p${rootpasswd} -e "create database nova_cell0; "
mysql -uroot -p${rootpasswd} -e "grant all privileges on nova_cell0.* to nova@'localhost' identified by 'password'; "
mysql -uroot -p${rootpasswd} -e "grant all privileges on nova_cell0.* to nova@'%' identified by 'password';"
mysql -uroot -p${rootpasswd} -e "create database placement; "
mysql -uroot -p${rootpasswd} -e "grant all privileges on placement.* to placement@'localhost' identified by 'password';"
mysql -uroot -p${rootpasswd} -e "grant all privileges on placement.* to placement@'%' identified by 'password'; "
mysql -uroot -p${rootpasswd} -e "flush privileges;"
echo " Add a User and Database on MariaDB for Neutron. "
mysql -uroot -p${rootpasswd} -e "create database neutron_ml2; "
mysql -uroot -p${rootpasswd} -e "grant all privileges on neutron_ml2.* to neutron@'localhost' identified by 'password'; "
mysql -uroot -p${rootpasswd} -e "grant all privileges on neutron_ml2.* to neutron@'%' identified by 'password'; "
mysql -uroot -p${rootpasswd} -e "flush privileges;"
echo "Add a User and Database on MariaDB for Cinder."
mysql -uroot -p${rootpasswd} -e "create database cinder;"
mysql -uroot -p${rootpasswd} -e "grant all privileges on cinder.* to cinder@'localhost' identified by 'password'; "
mysql -uroot -p${rootpasswd} -e "grant all privileges on cinder.* to cinder@'%' identified by 'password'; "
mysql -uroot -p${rootpasswd} -e "flush privileges; "
 



mysql -uroot -p${rootpasswd} -e ""