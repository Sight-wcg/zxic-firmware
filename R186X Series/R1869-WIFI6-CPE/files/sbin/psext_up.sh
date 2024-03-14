#!/bin/sh
test_log=`nv get telog_path`
if [ "$test_log" == "" ]; then
	test_log=`nv get path_log`"te.log"
fi
echo "Info: psext_up.sh $1 start" >> $test_log
path_conf=`nv get path_conf`

echo 1 > /proc/sys/net/ipv4/ip_forward
c_id=$1
ps_if=`nv get pswan`$c_id
eth_if=`nv get "ps_ext"$c_id`
ext_br="br"$c_id
pidfile=$path_conf"/udhcpd"$c_id".pid"
confile=$path_conf"/udhcpd"$c_id".conf"
leases=$path_conf"/udhcpd"$c_id".leases"

arp_proxy_set()
{
	(zte_arp_proxy -i $ext_br 2>> $test_log || echo "Error: zte_arp_proxy -i $ext_br failed." >> $test_log) &
}

dhcp_set()
{
    if [ -e ${pidfile} ]; then
      kill `cat $pidfile`
	  rm -f $pidfile
    fi
	touch $leases
	udhcpd -f $confile &
}

get_ipaddr()
{
    pdp_ip=`nv get $ps_if"_pdp_ip"`
	ps_ip=`nv get $ps_if"_ip"`
	br_ip=`nv get $ext_br"_ip"`
	ifconfig $ps_if $ps_ip up 2>>$test_log
	if [ $? -ne 0 ];then
	    echo "Error: ifconfig $ps_if $ps_ip up failed." >> $test_log
    fi
	nv set default_wan_rel=$ps_if
	nv set default_cid=$c_id
	nv set $ext_br"_ip"=$br_ip
	ifconfig $ext_br $br_ip 2>>$test_log
	if [ $? -ne 0 ];then
	    echo "Error: ifconfig $ext_br $br_ip up failed." >> $test_log
    fi
}
route_set()
{
    marknum=`expr $c_id + 20`
    iptables -t mangle -A PREROUTING -i $ps_if -j MARK --set-mark $marknum
	rt_num=`expr $c_id + 120`

    ip route add default dev $ext_br table $rt_num 	

	ip rule add to $pdp_ip fwmark $marknum table $rt_num

	marknum=`expr $c_id + 10`
    iptables -t mangle -A PREROUTING -i $ext_br -j MARK --set-mark $marknum
	rt_num=`expr $c_id + 100`

    ip route add default dev $ps_if table $rt_num
	ip rule add from $pdp_ip fwmark $marknum table $rt_num

	ip route flush cache

    iptables -t nat -I POSTROUTING -s $ps_ip -o $ps_if -j SNAT --to $pdp_ip

	route_info=`route|grep default`

	if [ "$route_info" == "" ];then
		route add default dev $ps_if
	else
		echo "Debug: default route already exist." >> $test_log
	fi
}

mtu=`nv get mtu`
ifconfig $ps_if mtu $mtu
brctl addbr $ext_br
brctl setfd $ext_br 0.1
brctl addif $ext_br $eth_if
ifconfig $ext_br up
get_ipaddr
dhcp_set
route_set
arp_proxy_set
ifconfig $eth_if up
ismbim=`ps |grep -v grep |grep -w mbim |awk '{printf $1}'`
if [ "-$ismbim" != "-" ]; then
	eth_mac=`cat "/sys/class/net/"$eth_if"/address"`
	arp -s $pdp_ip $eth_mac -i $ext_br 2>>$test_log
fi
tc_tbf.sh up $c_id
