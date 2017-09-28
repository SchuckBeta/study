#!/bin/bash
#network-creater.sh
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

#network
PUBLIC_NETWORK_FLOATING_IP_START=( $( __readINI $CONFIG_FILE PUBLIC_NETWORK floating_ip_start ) )
PUBLIC_NETWORK_FLOATING_IP_END=( $( __readINI $CONFIG_FILE PUBLIC_NETWORK floating_ip_end ) )
PUBLIC_NETWORK_GATEWAY=( $( __readINI $CONFIG_FILE PUBLIC_NETWORK gateway ) )
PUBLIC_NETWORK_DNS=( $( __readINI $CONFIG_FILE PUBLIC_NETWORK dns ) )
PUBLIC_NETWORK_CIDR=( $( __readINI $CONFIG_FILE PUBLIC_NETWORK cidr ) )
PRIVATE_NETWORK_GATEWAY=( $( __readINI $CONFIG_FILE PRIVATE_NETWORK gateway ) )
PRIVATE_NETWORK_CIDR=( $( __readINI $CONFIG_FILE PRIVATE_NETWORK cidr ) )

#use root
if [ `whoami` != "root" ]
then
  echo "Please use root account to run!"
  exit 1
fi

source /root/openrc.sh
#create ext net
neutron net-create ext-net --shared --router:external=True
neutron subnet-create ext-net --name ext-subnet \
--allocation-pool start=$PUBLIC_NETWORK_FLOATING_IP_START,end=$PUBLIC_NETWORK_FLOATING_IP_END \
--disable-dhcp --gateway $PUBLIC_NETWORK_GATEWAY --dns-nameserver $PUBLIC_NETWORK_DNS $PUBLIC_NETWORK_CIDR

#create user net
neutron net-create user-net
neutron subnet-create user-net --name user-subnet \
--gateway $PRIVATE_NETWORK_GATEWAY $PRIVATE_NETWORK_CIDR

#create router
neutron router-create user-router
neutron router-interface-add user-router user-subnet
neutron router-gateway-set user-router ext-net