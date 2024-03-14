#!/bin/sh

path_sh=`nv get path_sh`
. $path_sh/global.sh
echo "Info: firewall_init.sh start" >> $test_log


ZTE_FILTER_CHAIN=macipport_filter
ZTE_WEB_FILTER_CHAIN=web_filter
ZTE_CLILDREN_CHAIN=children_filter
ZTE_CLILDREN_WEB_CHAIN=children_web_filter
ZTE_CLILDREN_WEB_PHONECHAIN=children_web_filter_phone
REMO_RATELIMIT_CHAIN=remo_ratelimit
REMO_RATELIMIT_INTERFACE_CHAIN=remo_ratelimit_interface


iptables -t filter -F
iptables -t filter -X $ZTE_FILTER_CHAIN
iptables -t filter -X $ZTE_WEB_FILTER_CHAIN
iptables -t filter -X $ZTE_CLILDREN_CHAIN
iptables -t filter -X $ZTE_CLILDREN_WEB_CHAIN
iptables -t filter -X $ZTE_CLILDREN_WEB_PHONECHAIN
iptables -t filter -X $REMO_RATELIMIT_CHAIN
iptables -t filter -X $REMO_RATELIMIT_INTERFACE_CHAIN

ip6tables -t filter -F
ip6tables -t filter -X $ZTE_FILTER_CHAIN 
ip6tables -t filter -X $ZTE_WEB_FILTER_CHAIN	#add by tennry @20230705
ip6tables -t filter -X $REMO_RATELIMIT_INTERFACE_CHAIN   # summer.sun/add/2022.11.24

iptables -t filter -N $ZTE_FILTER_CHAIN
iptables -t filter -N $ZTE_WEB_FILTER_CHAIN
iptables -t filter -N $ZTE_CLILDREN_CHAIN
iptables -t filter -N $ZTE_CLILDREN_WEB_CHAIN
iptables -t filter -N $ZTE_CLILDREN_WEB_PHONECHAIN
ip6tables -t filter -N $ZTE_FILTER_CHAIN
ip6tables -t filter -N $ZTE_WEB_FILTER_CHAIN 	#add by tennry @20230705
ip6tables -t filter -N $REMO_RATELIMIT_INTERFACE_CHAIN  # summer.sun/add/2022.11.24
iptables -t filter -N $REMO_RATELIMIT_CHAIN
iptables -t filter -N $REMO_RATELIMIT_INTERFACE_CHAIN

iptables -t filter -A FORWARD -j $REMO_RATELIMIT_CHAIN
iptables -t filter -A FORWARD -j $REMO_RATELIMIT_INTERFACE_CHAIN
iptables -t filter -A FORWARD -j $ZTE_WEB_FILTER_CHAIN
iptables -t filter -A FORWARD -j $ZTE_FILTER_CHAIN
iptables -t filter -A FORWARD -j $ZTE_CLILDREN_CHAIN
iptables -t filter -A INPUT -j $ZTE_CLILDREN_WEB_CHAIN
iptables -t filter -A FORWARD -j $ZTE_CLILDREN_WEB_PHONECHAIN

ip6tables -t filter -A FORWARD -j $REMO_RATELIMIT_INTERFACE_CHAIN  # summer.sun/add/2022.11.24 
ip6tables -t filter -A FORWARD -j $ZTE_WEB_FILTER_CHAIN		#add by tennry @20230705
ip6tables -t filter -A FORWARD -j $ZTE_FILTER_CHAIN



iptables -t filter -A INPUT -i $defwan_rel -p udp --dport 53 -j DROP
iptables -t filter -A INPUT -i $defwan_rel -p tcp --dport 53 -j DROP
iptables -t filter -A INPUT -p tcp --dport 7777 -j DROP
iptables -t filter -A INPUT -p udp --dport 7777 -j DROP
iptables -t filter -I INPUT -i $defwan_rel -p icmp --icmp-type echo-reply -j ACCEPT

permit_gw=`nv get permit_gw`
permit_nm=`nv get permit_nm`
if [ "-${permit_gw}" != "-" ]; then
	iptables -A FORWARD -o $defwan_rel -d $permit_gw/$permit_nm -j ACCEPT
	iptables -A FORWARD -o $defwan_rel -j DROP
	iptables -A OUTPUT -o $defwan_rel -d $permit_gw/$permit_nm -j ACCEPT
	iptables -A OUTPUT -o $defwan_rel -j DROP
fi

permit_ip6=`nv get permit_ip6`
if [ "-${permit_ip6}" != "-" ]; then
	ip6tables -A FORWARD -o $defwan6_rel -d $permit_ip6 -j ACCEPT
	ip6tables -A FORWARD -o $defwan6_rel -j DROP
	ip6tables -A OUTPUT -o $defwan6_rel -d $permit_ip6 -j ACCEPT
	ip6tables -A OUTPUT -o $defwan6_rel -j DROP
fi


if [ "-$defwan_rel" == "-ppp0" ]; then
	mtu=`nv get mtu`
	pppoe_mtu=`expr $mtu - 60`
	iptables -A FORWARD -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --set-mss $pppoe_mtu
else
	iptables -A FORWARD -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu
fi

