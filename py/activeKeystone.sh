#!/bin/bash
#print date time on screen
echo "`date`"
echo "Active keystone"
cat keystonerc > ~/keystonerc
chmod 600 ~/keystonerc
source ~/keystonerc
echo 'source ~/keystonerc ' >> ~/.bash_profile 
source ~/.bash_profile
. ~/keystonerc
. ~/.bash_profile