#!/bin/bash
#setupControllerNode.sh

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
#mysql account
MYSQL_PASS=( $( __readINI $CONFIG_FILE MYSQL_USERS root_password ) )
KEYSTONE_DBUSER=( $( __readINI $CONFIG_FILE MYSQL_USERS keystone_db_username ) )
KEYSTONE_DBPASS=( $( __readINI $CONFIG_FILE MYSQL_USERS keystone_db_password ) )
GLANCE_DBUSER=( $( __readINI $CONFIG_FILE MYSQL_USERS glance_db_username ) )
GLANCE_DBPASS=( $( __readINI $CONFIG_FILE MYSQL_USERS glance_db_password ) )
NOVA_DBUSER=( $( __readINI $CONFIG_FILE MYSQL_USERS nova_db_username ) )
NOVA_DBPASS=( $( __readINI $CONFIG_FILE MYSQL_USERS nova_db_password ) )
NEUTRON_DBUSER=( $( __readINI $CONFIG_FILE MYSQL_USERS neutron_db_username ) )
NEUTRON_DBPASS=( $( __readINI $CONFIG_FILE MYSQL_USERS neutron_db_password ) )
#rabbit
RABBIT_PASSWORD=( $( __readINI $CONFIG_FILE RABBIT rabbit_password ) )
#service token
SERVICE_TOKEN=( $( __readINI $CONFIG_FILE SERVICE_TOKEN service_token ) )
#openstack user
ADMIN_USER=( $( __readINI $CONFIG_FILE OPENSTACK_USERS admin_username ) )
ADMIN_PASS=( $( __readINI $CONFIG_FILE OPENSTACK_USERS admin_password_PASS ) )
ADMIN_USER_EMAIL=( $( __readINI $CONFIG_FILE OPENSTACK_USERS admin_user_email ) )
GLANCE_USER=( $( __readINI $CONFIG_FILE OPENSTACK_USERS glance_username ) )
GLANCE_PASS=( $( __readINI $CONFIG_FILE OPENSTACK_USERS glance_password ) )
GLANCE_USER_EMAIL=( $( __readINI $CONFIG_FILE OPENSTACK_USERS glance_user_email ) )
NOVA_USER=( $( __readINI $CONFIG_FILE OPENSTACK_USERS nova_username ) )
NOVA_PASS=( $( __readINI $CONFIG_FILE OPENSTACK_USERS nova_password ) )
NOVA_USER_EMAIL=( $( __readINI $CONFIG_FILE OPENSTACK_USERS nova_user_email ) )
NEUTRON_USER=( $( __readINI $CONFIG_FILE OPENSTACK_USERS neutron_username ) )
NEUTRON_PASS=( $( __readINI $CONFIG_FILE OPENSTACK_USERS neutron_password ) )
NEUTRON_USER_EMAIL=( $( __readINI $CONFIG_FILE OPENSTACK_USERS neutron_user_email ) )
#openstack role
ADMIN_ROLE=( $( __readINI $CONFIG_FILE OPENSTACK_ROLES admin_role ) )
#openstack tanant
ADMIN_TENANT=( $( __readINI $CONFIG_FILE OPENSTACK_TENANTS admin_tenant ) )
ADMIN_TENANT_DESC=( $( __readINI $CONFIG_FILE OPENSTACK_TENANTSOPENSTACK_TENANTS admin_tenant_descriptiopn ) )
SERVICE_TENANT=( $( __readINI $CONFIG_FILE OPENSTACK_TENANTS service_tenant ) )
SERVICE_TENANT_DESC=( $( __readINI $CONFIG_FILE OPENSTACK_TENANTS service_tenant_description ) )
#controller node
CONTROLLER_NODE_HOSTNAME=( $( __readINI $CONFIG_FILE CONTROLLER_NODE hostname ) )
CONTROLLER_NODE_MANAGE_IP=( $( __readINI $CONFIG_FILE CONTROLLER_NODE manage_ip ) )
CONTROLLER_NODE_PUBLIC_IP=( $( __readINI $CONFIG_FILE CONTROLLER_NODE public_ip ) )
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

#metwork interface
echo -n "Input the manage network interface(default is eth0,press Enter to use default):"
read MANAGE_NETWORK_INTERFACE_NAME
if [ -z $MANAGE_NETWORK_INTERFACE_NAME ]
then
	MANAGE_NETWORK_INTERFACE_NAME="eth0"
fi

echo -n "Input the public network interface(default is eth1,press Enter to use default):"
read PUBLIC_NETWORK_INTERFACE_NAME
if [ -z $PUBLIC_NETWORK_INTERFACE_NAME ]
then
  PUBLIC_NETWORK_INTERFACE_NAME="eth1"
fi

#config ip
NETWORK_CONF=${NETWORK_CONF:-"/etc/network/interfaces"}
cat << INTERFACES > $NETWORK_CONF
auto lo
iface lo inet loopback

auto $MANAGE_NETWORK_INTERFACE_NAME
iface $MANAGE_NETWORK_INTERFACE_NAME inet static
address $CONTROLLER_NODE_MANAGE_IP
netmask $MANAGE_NETWORK_NETMASK

auto $PUBLIC_NETWORK_INTERFACE_NAME
iface $PUBLIC_NETWORK_INTERFACE_NAME inet static
address $CONTROLLER_NODE_PUBLIC_IP
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
echo $CONTROLLER_NODE_HOSTNAME > /etc/hostname
cat << EOF > /etc/hosts
127.0.0.1       localhost
127.0.1.1       $CONTROLLER_NODE_HOSTNAME
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
#config /etc/ntp.conf
sed -i 's/server ntp.ubuntu.com/server ntp.ubuntu.com\nserver 127.127.1.0\nfudge 127.127.1.0 stratum 10/g' /etc/ntp.conf
service ntp restart

#install mysql-server
cat << MYSQL_PRESEED | debconf-set-selections
mysql-server mysql-server/root_password password $MYSQL_PASS
mysql-server mysql-server/root_password_again password $MYSQL_PASS
mysql-server mysql-server/start_on_boot boolean true
MYSQL_PRESEED
apt-get install -y python-mysqldb mysql-server
#supprot remote access
sed -i "/^bind-address/s/127.0.0.1/$CONTROLLER_NODE_MANAGE_IP\ndefault-storage-engine = innodb\ninnodb_file_per_table\ncollation-server = utf8_general_ci\ninit-connect = 'SET NAMES utf8'\ncharacter-set-server = utf8/g" /etc/mysql/my.cnf
service mysql restart

apt-get install -y rabbitmq-server
rabbitmqctl change_password guest $RABBIT_PASSWORD

#=============================================keystone===================================================
#install identity service
apt-get install -y keystone
sed -i "s|^connection =.*$|connection=mysql://$KEYSTONE_DBUSER:$KEYSTONE_DBPASS@$CONTROLLER_NODE_HOSTNAME/keystone|g" /etc/keystone/keystone.conf
if [ -e /var/lib/keystone/keystone.db ]
then
	rm -rf /var/lib/keystone/keystone.db
fi
#create keystone database and user
mysql -uroot -p$MYSQL_PASS <<EOF
DROP DATABASE IF EXISTS keystone;
CREATE DATABASE keystone;
GRANT ALL PRIVILEGES ON keystone.* TO '$KEYSTONE_DBUSER'@'localhost' IDENTIFIED BY '$KEYSTONE_DBPASS';
GRANT ALL PRIVILEGES ON keystone.* TO '$KEYSTONE_DBUSER'@'%' IDENTIFIED BY '$KEYSTONE_DBPASS';
FLUSH PRIVILEGES;
EOF
#create tables
su -s /bin/sh -c "keystone-manage db_sync" keystone
#replace the admin_token
sed -i -e "s:^.*admin_token=.*$:admin_token=$SERVICE_TOKEN:g;s:^.*log_dir=.*$:log_dir=/var/log/keystone:g" /etc/keystone/keystone.conf
service keystone restart

#wait 3 second
sleep 3

#set the OS_SERVICE_TOKEN and OS_SERVICE_ENDPOINT environment variable
export OS_SERVICE_TOKEN="$SERVICE_TOKEN"
export OS_SERVICE_ENDPOINT="http://$CONTROLLER_NODE_HOSTNAME:35357/v2.0"

#create an administrative user
keystone user-create --name=$ADMIN_USER --pass=$ADMIN_PASS --email=$ADMIN_USER_EMAIL
keystone role-create --name=$ADMIN_ROLE
keystone tenant-create --name=$ADMIN_TENANT --description="$ADMIN_TENANT_DESC"
keystone user-role-add --user=$ADMIN_USER --tenant=$ADMIN_TENANT --role=$ADMIN_ROLE
keystone user-role-add --user=$ADMIN_USER --tenant=$ADMIN_TENANT --role=_member_ 

#create a service tenant
keystone tenant-create --name=$SERVICE_TENANT --description="$SERVICE_TENANT_DESC"

#create service and API endpoint
keystone service-create --name=keystone --type=identity --description="OpenStack Identity"
keystone endpoint-create \
  --service-id=$(keystone service-list | awk '/ identity / {print $2}') \
  --publicurl=http://$CONTROLLER_NODE_HOSTNAME:5000/v2.0 \
  --internalurl=http://$CONTROLLER_NODE_HOSTNAME:5000/v2.0 \
  --adminurl=http://$CONTROLLER_NODE_HOSTNAME:35357/v2.0

cat <<ENV_AUTH > /root/openrc.sh
export OS_TENANT_NAME=$ADMIN_TENANT
export OS_USERNAME=$ADMIN_USER
export OS_PASSWORD=$ADMIN_PASS
export OS_AUTH_URL="http://$CONTROLLER_NODE_HOSTNAME:35357/v2.0/"
ENV_AUTH
unset OS_SERVICE_TOKEN
unset OS_SERVICE_ENDPOINT

source /root/openrc.sh
#=============================================glance===================================================
apt-get install -y glance python-glanceclient
sed -i "s|^#connection =.*$|connection=mysql://$GLANCE_DBUSER:$GLANCE_DBPASS@$CONTROLLER_NODE_HOSTNAME/glance|g" /etc/glance/glance-api.conf
sed -i "s|^#connection =.*$|connection=mysql://$GLANCE_DBUSER:$GLANCE_DBPASS@$CONTROLLER_NODE_HOSTNAME/glance|g" /etc/glance/glance-registry.conf

if [ -e /var/lib/glance/glance.sqlite ]
then
	rm -rf /var/lib/glance/glance.sqlite
fi

#create glance database and user
mysql -uroot -p$MYSQL_PASS <<EOF
DROP DATABASE IF EXISTS glance;
CREATE DATABASE glance;
GRANT ALL PRIVILEGES ON glance.* TO '$GLANCE_DBUSER'@'localhost' IDENTIFIED BY '$GLANCE_DBPASS';
GRANT ALL PRIVILEGES ON glance.* TO '$GLANCE_DBUSER'@'%' IDENTIFIED BY '$GLANCE_DBPASS';
FLUSH PRIVILEGES;
EOF
#create tables
su -s /bin/sh -c "glance-manage db_sync" glance

#create glance user
keystone user-create --name=$GLANCE_USER --pass=$GLANCE_PASS --email=$GLANCE_USER_EMAIL
keystone user-role-add --user=$GLANCE_USER --tenant=$SERVICE_TENANT --role=$ADMIN_ROLE

#config glance-api-paste.ini and glance-registry.conf
sed -i -e "s/^auth_host =.*$/auth_host = $CONTROLLER_NODE_HOSTNAME/g;
           s/%SERVICE_TENANT_NAME%/$SERVICE_TENANT/g;
           s/%SERVICE_USER%/$GLANCE_USER/g;
           s/%SERVICE_PASSWORD%/$GLANCE_PASS/g;
           s/^#flavor=.*$/flavor=keystone/g" /etc/glance/glance-api.conf

sed -i -e "s/^auth_host =.*$/auth_host = $CONTROLLER_NODE_HOSTNAME/g;
           s/%SERVICE_TENANT_NAME%/$SERVICE_TENANT/g;
           s/%SERVICE_USER%/$GLANCE_USER/g;
           s/%SERVICE_PASSWORD%/$GLANCE_PASS/g;
           s/^#flavor=.*$/flavor=keystone/g" /etc/glance/glance-registry.conf

keystone service-create --name=glance --type=image --description="OpenStack Image Service"
keystone endpoint-create \
  --service-id=$(keystone service-list | awk '/ image / {print $2}') \
  --publicurl=http://$CONTROLLER_NODE_HOSTNAME:9292 \
  --internalurl=http://$CONTROLLER_NODE_HOSTNAME:9292 \
  --adminurl=http://$CONTROLLER_NODE_HOSTNAME:9292
service glance-registry restart
service glance-api restart

#=============================================nova===================================================
apt-get install -y nova-api nova-cert nova-conductor nova-consoleauth nova-novncproxy nova-scheduler python-novaclient

#config nova.conf
cat << EOF > /etc/nova/nova.conf
[DEFAULT]
dhcpbridge_flagfile=/etc/nova/nova.conf
dhcpbridge=/usr/bin/nova-dhcpbridge
logdir=/var/log/nova
state_path=/var/lib/nova
lock_path=/var/lock/nova
force_dhcp_release=True
iscsi_helper=tgtadm
libvirt_use_virtio_for_bridges=True
connection_type=libvirt
root_helper=sudo nova-rootwrap /etc/nova/rootwrap.conf
verbose=True
ec2_private_dns_show_ip=True
api_paste_config=/etc/nova/api-paste.ini
volumes_path=/var/lib/nova/volumes
enabled_apis=ec2,osapi_compute,metadata

#quota
quota_instances=100
quota_cores=100
quota_ram=51200
quota_max_injected_file_content_bytes=102400
quota_max_injected_files=50
quota_max_injected_file_path_bytes=4096
quota_metadata_items=1024
quota_volumes=100
quota_floating_ips=100
quota_gigabytes=1000
quota_security_groups=10
quota_security_groups_rules=20
quota_key_paris=10

network_api_class = nova.network.neutronv2.api.API
neutron_url = http://$CONTROLLER_NODE_HOSTNAME:9696
neutron_auth_strategy = keystone
neutron_admin_tenant_name = $SERVICE_TENANT
neutron_admin_username = $NEUTRON_USER
neutron_admin_password = $NEUTRON_PASS
neutron_admin_auth_url = http://$CONTROLLER_NODE_HOSTNAME:35357/v2.0
linuxnet_interface_driver = nova.network.linux_net.LinuxOVSInterfaceDriver
firewall_driver = nova.virt.firewall.NoopFirewallDriver
security_group_api = neutron

service_neutron_metadata_proxy = true
neutron_metadata_proxy_shared_secret = METADATA_SECRET

auth_strategy = keystone
[keystone_authtoken]
auth_uri = http://$CONTROLLER_NODE_HOSTNAME:5000
auth_host = $CONTROLLER_NODE_HOSTNAME
auth_port = 35357
auth_protocol = http
admin_tenant_name = $SERVICE_TENANT
admin_user = $NOVA_USER
admin_password = $NOVA_PASS

[database]
connection = mysql://$NOVA_DBUSER:$NOVA_DBPASS@$CONTROLLER_NODE_HOSTNAME/nova
[DEFAULT]
rpc_backend = rabbit
rabbit_host = $CONTROLLER_NODE_HOSTNAME
rabbit_password = $RABBIT_PASSWORD
my_ip = $CONTROLLER_NODE_MANAGE_IP
vncserver_listen = $CONTROLLER_NODE_MANAGE_IP
vncserver_proxyclient_address = $CONTROLLER_NODE_MANAGE_IP
EOF

if [ -e /var/lib/nova/nova.sqlite ]
then
  rm -rf /var/lib/nova/nova.sqlite
fi

#create nova database and user
mysql -uroot -p$MYSQL_PASS <<EOF
DROP DATABASE IF EXISTS nova;
CREATE DATABASE nova;
GRANT ALL PRIVILEGES ON nova.* TO '$NOVA_DBUSER'@'localhost' IDENTIFIED BY '$NOVA_DBPASS';
GRANT ALL PRIVILEGES ON nova.* TO '$NOVA_DBUSER'@'%' IDENTIFIED BY '$NOVA_DBPASS';
FLUSH PRIVILEGES;
EOF
#create tables
su -s /bin/sh -c "nova-manage db sync" nova

#create nova user
keystone user-create --name=$NOVA_USER --pass=$NOVA_PASS --email=$NOVA_USER_EMAIL
keystone user-role-add --user=$NOVA_USER --tenant=$SERVICE_TENANT --role=$ADMIN_ROLE

#create service and API endpoint
keystone service-create --name=nova --type=compute --description="OpenStack Compute"
keystone endpoint-create \
  --service-id=$(keystone service-list | awk '/ compute / {print $2}') \
  --publicurl=http://$CONTROLLER_NODE_HOSTNAME:8774/v2/%\(tenant_id\)s \
  --internalurl=http://$CONTROLLER_NODE_HOSTNAME:8774/v2/%\(tenant_id\)s \
  --adminurl=http://$CONTROLLER_NODE_HOSTNAME:8774/v2/%\(tenant_id\)s

service nova-api restart
service nova-cert restart
service nova-consoleauth restart
service nova-scheduler restart
service nova-conductor restart
service nova-novncproxy restart
#===========================================neutron=======================================================
apt-get install -y neutron-server neutron-plugin-ml2

#create neutron database and user
mysql -uroot -p$MYSQL_PASS <<EOF
DROP DATABASE IF EXISTS neutron;
CREATE DATABASE neutron;
GRANT ALL PRIVILEGES ON neutron.* TO '$NEUTRON_DBUSER'@'localhost' IDENTIFIED BY '$NEUTRON_DBPASS';
GRANT ALL PRIVILEGES ON neutron.* TO '$NEUTRON_DBUSER'@'%' IDENTIFIED BY '$NEUTRON_DBPASS';
FLUSH PRIVILEGES;
EOF

#create neutron user
keystone user-create --name $NEUTRON_USER --pass $NEUTRON_PASS --email $NEUTRON_USER_EMAIL
keystone user-role-add --user $NEUTRON_USER --tenant $SERVICE_TENANT --role $ADMIN_ROLE

#create service and API endpoint
keystone service-create --name neutron --type network --description "OpenStack Networking"
keystone endpoint-create \
  --service-id $(keystone service-list | awk '/ network / {print $2}') \
  --publicurl http://$CONTROLLER_NODE_HOSTNAME:9696 \
  --adminurl http://$CONTROLLER_NODE_HOSTNAME:9696 \
  --internalurl http://$CONTROLLER_NODE_HOSTNAME:9696

sed -i -e "s|^connection =.*$|connection = mysql://$NEUTRON_DBUSER:$NEUTRON_DBPASS@$CONTROLLER_NODE_HOSTNAME/neutron|g;
           s|^# auth_strategy =.*$|auth_strategy = keystone|g;
           s|^# rpc_backend =.*$|rpc_backend = neutron.openstack.common.rpc.impl_kombu|g;
           s|^# rabbit_host =.*$|rabbit_host = $CONTROLLER_NODE_HOSTNAME|g;
           s|^# rabbit_password =.*$|rabbit_password = $RABBIT_PASSWORD|g;
           s|^# notify_nova_on_port_status_changes =.*$|notify_nova_on_port_status_changes = True|g;
           s|^# notify_nova_on_port_data_changes =.*$|notify_nova_on_port_data_changes = True|g;
           s|^# nova_url =.*$|nova_url = http://$CONTROLLER_NODE_HOSTNAME:8774/v2|g;
           s|^# nova_admin_username =.*$|nova_admin_username = $NOVA_USER|g;
           s|^# nova_admin_tenant_id =.*$|nova_admin_tenant_id = $(keystone tenant-list | awk '/ service / { print $2 }')|g;
           s|^# nova_admin_password =.*$|nova_admin_password = $NOVA_PASS|g;
           s|^# nova_admin_auth_url =.*$|nova_admin_auth_url = http://$CONTROLLER_NODE_HOSTNAME:35357/v2.0|g;
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

[securitygroup]
firewall_driver = neutron.agent.linux.iptables_firewall.OVSHybridIptablesFirewallDriver
enable_security_group = True
EOF

service nova-api restart
service nova-scheduler restart
service nova-conductor restart
service neutron-server restart
#==========================================dashboard======================================================
apt-get install -y apache2 memcached libapache2-mod-wsgi openstack-dashboard
apt-get remove -y --purge openstack-dashboard-ubuntu-theme
service apache2 restart
service memcached restart

#===========================================secgroup======================================================
nova secgroup-add-rule default icmp -1 -1 0.0.0.0/0
nova secgroup-add-rule default tcp 22 22 0.0.0.0/0
nova secgroup-add-rule default tcp 3389 3389 0.0.0.0/0

#=========================================upload cirros===================================================
#upload cirros
glance image-create --name="cirros-0.3.2-x86_64" --disk-format=qcow2 \
                    --container-format=bare --is-public=true \
                    --copy-from http://$SOURCES_SERVER_IP/glance/cirros-0.3.2-x86_64-disk.img