#!/bin/bash
source ../module/echo.sh
source VARIABLE.sh
# red=`tput setaf 1`
# green=`tput setaf 2`
# reset=`tput sgr0`
echo_noti "define Neutron API Host"
# controller="controller"
echo $controller

echo_job_detail "Config Neutron"
echo_noti "create [neutron] user in [service] project"
openstack user create --domain default --project service --password servicepassword neutron
echo_noti "add [neutron] user in [admin] role"
openstack role add --project service --user neutron admin
echo_noti "create service entry for [neutron]"
openstack service create --name neutron --description "OpenStack Networking service" network
echo_noti "create endpoint for [neutron] (public)"
openstack endpoint create --region RegionOne network public http://$controller:9696
echo_noti "create endpoint for [neutron] (internal)"
openstack endpoint create --region RegionOne network internal http://$controller:9696
echo_noti "create endpoint for [neutron] (admin)"
openstack endpoint create --region RegionOne network admin http://$controller:9696

echo_job_detail "Install Neutron services on host Controller"
echo_noti "install from Victoria, EPEL, powertools"
dnf --enablerepo=centos-openstack-victoria,powertools,epel -y install openstack-neutron openstack-neutron-ml2 openstack-neutron-openvswitch
echo_job_detail "Configure Neutron services."
mv /etc/neutron/neutron.conf /etc/neutron/neutron.conf.org
echo_noti "Creating config file"
cat ../config_file/neutron.conf
sleep 5
cat ../config_file/neutron.conf > /etc/neutron/neutron.conf
chmod 640 /etc/neutron/neutron.conf
chgrp neutron /etc/neutron/neutron.conf
echo_noti "Modify /etc/neutron/l3_agent.ini"
python3 ../module/add_text_to_line.py "/etc/neutron/l3_agent.ini" "[DEFAULT]" "interface_driver = openvswitch"
echo_noti "Modify /etc/neutron/dhcp_agent.ini"
python3 ../module/add_text_to_line.py "/etc/neutron/dhcp_agent.ini" "[DEFAULT]" "interface_driver = openvswitch"
python3 ../module/add_text_to_line.py "/etc/neutron/dhcp_agent.ini" "interface_driver = openvswitch" "dhcp_driver = neutron.agent.linux.dhcp.Dnsmasq"
python3 ../module/add_text_to_line.py "/etc/neutron/dhcp_agent.ini" "dhcp_driver = neutron.agent.linux.dhcp.Dnsmasq" "enable_isolated_metadata = true"
echo_noti "Modify /etc/neutron/metadata_agent.ini"
python3 ../module/add_text_to_line.py "/etc/neutron/metadata_agent.ini" "[DEFAULT]" "nova_metadata_host = $controller # specify Nova API server"
python3 ../module/add_text_to_line.py "/etc/neutron/metadata_agent.ini" "nova_metadata_host = $controller # specify Nova API server" "metadata_proxy_shared_secret = metadata_secret # specify any secret key you like"
echo_noti "Add specify Memcache server to /etc/neutron/metadata_agent.ini"
python3 ../module/find_and_replace.py "/etc/neutron/metadata_agent.ini" "#memcache_servers = localhost:11211" "memcache_servers = $controller:11211"
echo_noti "Modify /etc/neutron/plugins/ml2/ml2_conf.ini"
echo -e "\n[ml2]\ntype_drivers = flat,vlan,gre,vxlan\ntenant_network_types = vxlan\nmechanism_drivers = openvswitch\nextension_drivers = port_security\n" >> /etc/neutron/plugins/ml2/ml2_conf.ini
echo_noti "Modify /etc/neutron/plugins/ml2/openvswitch_agent.ini"
echo -e "\n[securitygroup]\nfirewall_driver = openvswitch\nenable_security_group = true\nenable_ipset = true\n" >> /etc/neutron/plugins/ml2/openvswitch_agent.ini
echo_noti "Modify /etc/neutron/plugins/ml2/openvswitch_agent.ini"
python3 ../module/add_text_to_line.py "/etc/nova/nova.conf" "[DEFAULT]" "use_neutron = True"
python3 ../module/add_text_to_line.py "/etc/nova/nova.conf" "use_neutron = True" "linuxnet_interface_driver = nova.network.linux_net.LinuxOVSInterfaceDriver"
python3 ../module/add_text_to_line.py "/etc/nova/nova.conf" "linuxnet_interface_driver = nova.network.linux_net.LinuxOVSInterfaceDriver" "firewall_driver = nova.virt.firewall.NoopFirewallDriver"
python3 ../module/add_text_to_line.py "/etc/nova/nova.conf" "firewall_driver = nova.virt.firewall.NoopFirewallDriver" "vif_plugging_is_fatal = True"
python3 ../module/add_text_to_line.py "/etc/nova/nova.conf" "vif_plugging_is_fatal = True" "vif_plugging_timeout = 300"
echo -e "\n # add follows to the end : Neutron auth info \n" >> /etc/nova/nova.conf
echo -e "\n[neutron]\nauth_url = http://$controller:5000\nauth_type = password\nproject_domain_name = default\nuser_domain_name = default\nregion_name = RegionOne\nproject_name = service\nusername = neutron\npassword = servicepassword\nservice_metadata_proxy = True\nmetadata_proxy_shared_secret = metadata_secret\n"
echo_noti "If SELinux is enabled, change policy."
dnf --enablerepo=centos-openstack-victoria -y install openstack-selinux
setsebool -P neutron_can_network on
setsebool -P haproxy_connect_any on
setsebool -P daemons_enable_cluster_mode on
checkmodule -m -M -o ovsofctl.mod ovsofctl.te
semodule_package --outfile ovsofctl.pp --module ovsofctl.mod
semodule -i ovsofctl.pp
echo_noti "If Firewalld is running, allow ports for services."
firewall-cmd --add-port=9696/tcp --permanent
firewall-cmd --reload
echo_noti "Start Neutron services."
systemctl enable --now openvswitch
ovs-vsctl add-br br-int
ln -s /etc/neutron/plugins/ml2/ml2_conf.ini /etc/neutron/plugin.ini
su -s /bin/bash neutron -c "neutron-db-manage --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/plugin.ini upgrade head"
for service in server dhcp-agent l3-agent metadata-agent openvswitch-agent; do systemctl enable --now neutron-$service; done
systemctl restart openstack-nova-api openstack-nova-compute
openstack network agent list
echo_noti "Installed neutron"
echo_job_detail "Configure Neutron Server"
#mv /etc/neutron/neutron.conf /etc/neutron/neutron.conf.org
echo_noti "Config NEUTRON VXLAN"
echo -e "\n# add to the end\n[ml2_type_flat]\nflat_networks = physnet1\n[ml2_type_vxlan]\nvni_ranges = 1:1000\nsystemctl restart neutron-server\n" >> /etc/neutron/plugins/ml2/ml2_conf.ini
systemctl restart neutron-server
echo_noti "Modify /etc/neutron/plugins/ml2/openvswitch_agent.ini"
echo -e "\n# add to the end\n[securitygroup]\nfirewall_driver = openvswitch\nenable_security_group = true\nenable_ipset = true\n\n[agent]\ntunnel_types = vxlan\nprevent_arp_spoofing = True\n\n[ovs]\nlocal_ip = $controller\nbridge_mappings = physnet1:br-ex\n" >> /etc/neutron/plugins/ml2/openvswitch_agent.ini
for service in dhcp-agent l3-agent metadata-agent openvswitch-agent; do systemctl restart neutron-$service; done
echo_noti "Setting up Networking"
openstack router create router01
openstack network create private --provider-network-type vxlan
openstack subnet create private-subnet --network private --subnet-range 10.0.0.0/24 --gateway 10.0.0.1 --dns-nameserver 192.168.1.1
openstack router add subnet router01 private-subnet
openstack network create --provider-physical-network physnet1 --provider-network-type flat --external public
systemctl restart neutron-openvswitch-agent
openstack subnet create public-subnet --network public --subnet-range 192.168.1.0/24 --allocation-pool start=192.168.1.150,end=192.168.1.254 --gateway 192.168.1.1 --dns-nameserver 8.8.8.8 --no-dhcp
openstack router set router01 --external-gateway public
openstack port list

#python3 ../module/find_and_replace.py "/Users/hungnt/project/bash/op/py/bash/test" "haha" "hee hee"