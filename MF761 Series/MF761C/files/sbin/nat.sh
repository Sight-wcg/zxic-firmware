#!/bin/sh
#
# $Id: nat.sh,v 1.4 2009-12-09 08:45:37 steven Exp $
#
# usage: nat.sh
#

path_sh=`nv get path_sh`
. $path_sh/global.sh
echo "Info: nat.sh start " >> $test_log

ZTE_FORWARD_CHAIN=port_forward
ZTE_DMZ_CHAIN=DMZ
ZTE_MAPPING_CHAIN=port_mapping

iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT
iptables -P FORWARD ACCEPT

#clear nat
iptables -t nat -F
iptables -t nat -X $ZTE_FORWARD_CHAIN
iptables -t nat -X $ZTE_DMZ_CHAIN
iptables -t nat -X $ZTE_MAPPING_CHAIN


#Make a new chain for nat
iptables -t nat -N $ZTE_FORWARD_CHAIN
iptables -t nat -N $ZTE_DMZ_CHAIN
iptables -t nat -N $ZTE_MAPPING_CHAIN

iptables -t nat -I PREROUTING 1 -j $ZTE_FORWARD_CHAIN
iptables -t nat -I PREROUTING 1 -j $ZTE_DMZ_CHAIN
iptables -t nat -I PREROUTING 1 -j $ZTE_MAPPING_CHAIN
	
	lan_en=`nv get LanEnable`
	nat_en=`nv get natenable`
	if [ "-$nat_en" != "-0" -a "-$lan_en" == "-2" ]; then
	    iptables -t nat -A POSTROUTING -o ${defwan_rel%:*} -j MASQUERADE
	elif [ "-$nat_en" != "-0" -a "-$lan_en" != "-0" ]; then
		iptables -t nat -A POSTROUTING -o $defwan_rel -j MASQUERADE
	fi

clat46_en=1
	if [ "-$clat46_en" = "-1" ]; then
		iptables -t nat -A POSTROUTING -o clat4 -j MASQUERADE
	fi
  
  
