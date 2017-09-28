#!/bin/bash
#addNetworkNode.sh

#check config.ini
CONFIG_FILE=config.ini
if [ ! -s $CONFIG_FILE ]
then
  echo "Can not find config.ini!"
  exit 1
fi

function __readINI() 
{
  INIFILE=$1
  SECTION=$2
  ITEM=$3
  ITEM_VALUE=`awk -F '=' '/\['$SECTION'\]/{a=1}a==1&&$1~/'$ITEM'/{print $2;exit}' $INIFILE`
  echo ${ITEM_VALUE}
}

#sources server
SOURCES_SERVER_IP=( $( __readINI $CONFIG_FILE SOURCES_SERVER ip ) )
#rabbit
RABBIT_PASSWORD=( $( __readINI $CONFIG_FILE RABBIT rabbit_password ) )
#openstack user
NEUTRON_USER=( $( __readINI $CONFIG_FILE OPENSTACK_USERS neutron_username ) )
NEUTRON_PASS=( $( __readINI $CONFIG_FILE OPENSTACK_USERS neutron_password ) )
NEUTRON_USER_EMAIL=( $( __readINI $CONFIG_FILE OPENSTACK_USERS neutron_user_email ) )
#openstack tanant
SERVICE_TENANT=( $( __readINI $CONFIG_FILE OPENSTACK_TENANTS service_tenant ) )
#controller node
CONTROLLER_NODE_HOSTNAME=( $( __readINI $CONFIG_FILE CONTROLLER_NODE hostname ) )
CONTROLLER_NODE_MANAGE_IP=( $( __readINI $CONFIG_FILE CONTROLLER_NODE manage_ip ) )
#network
MANAGE_NETWORK_NETMASK=( $( __readINI $CONFIG_FILE MANAGE_NETWORK netmask ) )
PUBLIC_NETWORK_NETMASK=( $( __readINI $CONFIG_FILE PUBLIC_NETWORK netmask ) )
PUBLIC_NETWORK_GATEWAY=( $( __readINI $CONFIG_FILE PUBLIC_NETWORK gateway ) )
PUBLIC_NETWORK_DNS=( $( __readINI $CONFIG_FILE PUBLIC_NETWORK dns ) )

#use root
if [ `whoami` != "root" ]
then
  echo "Please use root account to run!"
  exit 1
fi

#config language
sed -i -e 's/zh_CN.UTF-8/en_US.UTF-8/g' /etc/default/locale
sed -i -e 's/zh_CN:zh/en_US:en/g' /etc/default/locale
sed -i -e 's/zh_CN/en_US/g' /etc/default/locale

#hostname
echo -n "Input hostname of the network node :"
read NETWORK_NODE_HOSTNAME

#metwork interface
echo -n "Input the manage network interface(default is eth0,press Enter to use default):"
read MANAGE_NETWORK_INTERFACE_NAME
if [ -z $MANAGE_NETWORK_INTERFACE_NAME ]
then
  MANAGE_NETWORK_INTERFACE_NAME="eth0"
fi

echo -n "Input the manage network IP :"
read NETWORK_NODE_MANAGE_IP

echo -n "Input the public network interface(default is eth1,press Enter to use default):"
read PUBLIC_NETWORK_INTERFACE_NAME
if [ -z $PUBLIC_NETWORK_INTERFACE_NAME ]
then
  PUBLIC_NETWORK_INTERFACE_NAME="eth1"
fi

echo -n "Input the public network IP :"
read NETWORK_NODE_PUBLIC_IP

#config ip
NETWORK_CONF=${NETWORK_CONF:-"/etc/network/interfaces"}
cat << INTERFACES > $NETWORK_CONF
auto lo
iface lo inet loopback

auto $MANAGE_NETWORK_INTERFACE_NAME
iface $MANAGE_NETWORK_INTERFACE_NAME inet static
address $NETWORK_NODE_MANAGE_IP
netmask $MANAGE_NETWORK_NETMASK

auto $PUBLIC_NETWORK_INTERFACE_NAME
iface $PUBLIC_NETWORK_INTERFACE_NAME inet static
address $NETWORK_NODE_PUBLIC_IP
netmask $PUBLIC_NETWORK_NETMASK
gateway $PUBLIC_NETWORK_GATEWAY
dns-nameservers $PUBLIC_NETWORK_DNS
INTERFACES

ifdown $MANAGE_NETWORK_INTERFACE_NAME
ifup $MANAGE_NETWORK_INTERFACE_NAME

ifdown $PUBLIC_NETWORK_INTERFACE_NAME
ifup $PUBLIC_NETWORK_INTERFACE_NAME

#test connetct sources ip
echo "test network connection ..."
if ping -w 1 -c 1 $SOURCES_SERVER_IP | grep "100%" >/dev/null  
then
  echo "can not connetct to the sources host"
  exit 1
else
  echo "network successfully ..."
fi

#config hostname
echo $NETWORK_NODE_HOSTNAME > /etc/hostname
cat << EOF > /etc/hosts
127.0.0.1       localhost
127.0.1.1       $NETWORK_NODE_HOSTNAME
$NETWORK_NODE_MANAGE_IP       $NETWORK_NODE_HOSTNAME
$CONTROLLER_NODE_MANAGE_IP       $CONTROLLER_NODE_HOSTNAME
# The following lines are desirable for IPv6 capable hosts
::1     localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
EOF
service hostname start

sed -i -e 's/GRUB_HIDDEN_TIMEOUT_QUIET=true/#GRUB_HIDDEN_TIMEOUT_QUIET=true/g' /etc/default/grub

#update source
cat << EOF > /etc/apt/sources.list
deb http://$SOURCES_SERVER_IP/ubuntu/ trusty main restricted universe multiverse 
deb http://$SOURCES_SERVER_IP/ubuntu/ trusty-security main restricted universe multiverse 
deb http://$SOURCES_SERVER_IP/ubuntu/ trusty-updates main restricted universe multiverse 
deb http://$SOURCES_SERVER_IP/ubuntu/ trusty-proposed main restricted universe multiverse 
deb http://$SOURCES_SERVER_IP/ubuntu/ trusty-backports main restricted universe multiverse 
EOF

apt-get update

#install openssh-server
apt-get install -y openssh-server
#allow root login
sed -i -e 's/PermitRootLogin without-password/PermitRootLogin yes/g' /etc/ssh/sshd_config
service ssh restart

#install ntp
apt-get install -y ntp
#edit /etc/ntp.conf
sed -i -e "s/server ntp.ubuntu.com/server $CONTROLLER_NODE_MANAGE_IP/g" /etc/ntp.conf
service ntp restart

#install python-mysqldb
apt-get install -y python-mysqldb

#install neutron components
sed -i -e "s|^net.ipv4.ip_forward=.*$|net.ipv4.ip_forward=1|g;
           s|^net.ipv4.conf.all.rp_filter=.*$|net.ipv4.conf.all.rp_filter=0|g;
           s|^net.ipv4.conf.default.rp_filter=.*$|net.ipv4.conf.default.rp_filter=0|g;" /etc/sysctl.conf
sysctl -p

apt-get install -y neutron-plugin-ml2 neutron-plugin-openvswitch-agent neutron-l3-agent neutron-dhcp-agent

sed -i -e "s|^# auth_strategy =.*$|auth_strategy = keystone|g;
           s|^# rpc_backend =.*$|rpc_backend = neutron.openstack.common.rpc.impl_kombu|g;
           s|^# rabbit_host =.*$|rabbit_host = $CONTROLLER_NODE_HOSTNAME|g;
           s|^# rabbit_password =.*$|rabbit_password = $RABBIT_PASSWORD|g;
           s|^core_plugin =.*$|core_plugin = ml2|g;
           s|^# service_plugins =.*$|service_plugins = router|g;
           s|^# allow_overlapping_ips =.*$|allow_overlapping_ips = True|g;
           s|^auth_host =.*$|auth_host = $CONTROLLER_NODE_HOSTNAME|g;
           s|^admin_tenant_name =.*$|admin_tenant_name = $SERVICE_TENANT|g;
           s|^admin_user =.*$|admin_user = $NEUTRON_USER|g;
           s|^admin_password =.*$|admin_password = $NEUTRON_PASS|g;" /etc/neutron/neutron.conf

cat << EOF > /etc/neutron/plugins/ml2/ml2_conf.ini
[ml2]
type_drivers = gre
tenant_network_types = gre
mechanism_drivers = openvswitch

[ml2_type_gre]
tunnel_id_ranges = 1:1000

[ovs]
local_ip = $NETWORK_NODE_MANAGE_IP
tunnel_type = gre
enable_tunneling = True

[securitygroup]
firewall_driver = neutron.agent.linux.iptables_firewall.OVSHybridIptablesFirewallDriver
enable_security_group = True
EOF

sed -i -e "s|^# interface_driver =.*$|interface_driver = neutron.agent.linux.interface.OVSInterfaceDriver|g;
           s|^# use_namespaces =.*$|use_namespaces = True|g;" /etc/neutron/l3_agent.ini

sed -i -e "s|^# interface_driver =.*$|interface_driver = neutron.agent.linux.interface.OVSInterfaceDriver|g;
           s|^# dhcp_driver =.*$|dhcp_driver = neutron.agent.linux.dhcp.Dnsmasq|g;
           s|^# use_namespaces =.*$|use_namespaces = True|g;
           s|^# dnsmasq_config_file =.*$|dnsmasq_config_file = /etc/neutron/dnsmasq-neutron.conf|g;" /etc/neutron/dhcp_agent.ini

cat << EOF > /etc/neutron/dnsmasq-neutron.conf
dhcp-option-force=26,1454
EOF

killall dnsmasq

sed -i -e "s|^auth_url =.*$|auth_url = http://$CONTROLLER_NODE_HOSTNAME:5000/v2.0|g;
           s|^admin_tenant_name =.*$|admin_tenant_name = $SERVICE_TENANT|g;
           s|^admin_user =.*$|admin_user = $NEUTRON_USER|g;
           s|^admin_password =.*$|admin_password = $NEUTRON_PASS|g;
           s|^# nova_metadata_ip =.*$|nova_metadata_ip = $CONTROLLER_NODE_HOSTNAME|g;
           s|^# metadata_proxy_shared_secret =.*$|metadata_proxy_shared_secret = METADATA_SECRET|g;" /etc/neutron/metadata_agent.ini

service openvswitch-switch restart

#modify ip
#config ip
cat << INTERFACES > $NETWORK_CONF
auto lo
iface lo inet loopback

auto $MANAGE_NETWORK_INTERFACE_NAME
iface $MANAGE_NETWORK_INTERFACE_NAME inet static
address $NETWORK_NODE_MANAGE_IP
netmask $MANAGE_NETWORK_NETMASK

auto $PUBLIC_NETWORK_INTERFACE_NAME
iface $PUBLIC_NETWORK_INTERFACE_NAME inet manual
up ip link set dev $PUBLIC_NETWORK_INTERFACE_NAME up
down ip link set dev $PUBLIC_NETWORK_INTERFACE_NAME down
INTERFACES

ifdown $PUBLIC_NETWORK_INTERFACE_NAME
ifup $PUBLIC_NETWORK_INTERFACE_NAME

ovs-vsctl add-br br-int
ovs-vsctl add-br br-ex
ovs-vsctl add-port br-ex $PUBLIC_NETWORK_INTERFACE_NAME

service neutron-plugin-openvswitch-agent restart
service neutron-l3-agent restart
service neutron-dhcp-agent restart
service neutron-metadata-agent restart