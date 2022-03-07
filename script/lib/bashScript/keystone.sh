#!/bin/bash
# source module/echo.sh
#print date time on screen
echo "`date`"
controller=


su -s /bin/bash keystone -c "keystone-manage db_sync"
echo"initialize Fernet key"
keystone-manage fernet_setup --keystone-user keystone --keystone-group keystone
keystone-manage credential_setup --keystone-user keystone --keystone-group keystone
keystone-manage bootstrap --bootstrap-password adminpassword --bootstrap-admin-url http://$controller:5000/v3/ --bootstrap-internal-url http://$controller:5000/v3/ --bootstrap-public-url http://$controller:5000/v3/ --bootstrap-region-id RegionOne