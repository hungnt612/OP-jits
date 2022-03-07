#!/bin/bash
# source module/echo.sh
#print date time on screen
echo "`date`"
controller=controller


rootpasswd='admin' 

sudo mysql -uroot -p${rootpasswd} -e

echo "CONFIG KEYSTONEEEEEEEEEEEEEEE"
echo "Add a User and Database on MariaDB for Keystone."
sudo mysql -uroot -p${rootpasswd} -e "create database keystone;"
sudo mysql -uroot -p${rootpasswd} -e "grant all privileges on keystone.* to keystone@'localhost' identified by 'password';"
sudo mysql -uroot -p${rootpasswd} -e "grant all privileges on keystone.* to keystone@'%' identified by 'password';"
sudo mysql -uroot -p${rootpasswd} -e "flush privileges;"
echo "Add a User and Database on MariaDB for Glance."
sudo mysql -uroot -p${rootpasswd} -e "create database glance;"
sudo mysql -uroot -p${rootpasswd} -e "grant all privileges on glance.* to glance@'localhost' identified by 'password'; "
sudo mysql -uroot -p${rootpasswd} -e "grant all privileges on glance.* to glance@'%' identified by 'password'; "
sudo mysql -uroot -p${rootpasswd} -e "flush privileges; "
echo "Add a User and Database on MariaDB for Nova."
sudo mysql -uroot -p${rootpasswd} -e "create database nova; "
sudo mysql -uroot -p${rootpasswd} -e "grant all privileges on nova.* to nova@'localhost' identified by 'password'; "
sudo mysql -uroot -p${rootpasswd} -e "grant all privileges on nova.* to nova@'%' identified by 'password'; "
sudo mysql -uroot -p${rootpasswd} -e "create database nova_api; "
sudo mysql -uroot -p${rootpasswd} -e "grant all privileges on nova_api.* to nova@'localhost' identified by 'password'; "
sudo mysql -uroot -p${rootpasswd} -e "grant all privileges on nova_api.* to nova@'%' identified by 'password'; "
sudo mysql -uroot -p${rootpasswd} -e "create database nova_cell0; "
sudo mysql -uroot -p${rootpasswd} -e "grant all privileges on nova_cell0.* to nova@'localhost' identified by 'password'; "
sudo mysql -uroot -p${rootpasswd} -e "grant all privileges on nova_cell0.* to nova@'%' identified by 'password';"
sudo mysql -uroot -p${rootpasswd} -e "create database placement; "
sudo mysql -uroot -p${rootpasswd} -e "grant all privileges on placement.* to placement@'localhost' identified by 'password';"
sudo mysql -uroot -p${rootpasswd} -e "grant all privileges on placement.* to placement@'%' identified by 'password'; "
sudo mysql -uroot -p${rootpasswd} -e "flush privileges;"
echo " Add a User and Database on MariaDB for Neutron. "
sudo mysql -uroot -p${rootpasswd} -e "create database neutron_ml2; "
sudo mysql -uroot -p${rootpasswd} -e "grant all privileges on neutron_ml2.* to neutron@'localhost' identified by 'password'; "
sudo mysql -uroot -p${rootpasswd} -e "grant all privileges on neutron_ml2.* to neutron@'%' identified by 'password'; "
sudo mysql -uroot -p${rootpasswd} -e "flush privileges;"
echo "Add a User and Database on MariaDB for Cinder."
sudo mysql -uroot -p${rootpasswd} -e "create database cinder;"
sudo mysql -uroot -p${rootpasswd} -e "grant all privileges on cinder.* to cinder@'localhost' identified by 'password'; "
sudo mysql -uroot -p${rootpasswd} -e "grant all privileges on cinder.* to cinder@'%' identified by 'password'; "
sudo mysql -uroot -p${rootpasswd} -e "flush privileges; "




# mysql -uroot -p${rootpasswd} -e ""