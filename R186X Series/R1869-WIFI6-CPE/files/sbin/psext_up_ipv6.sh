#!/bin/sh
test_log=`nv get telog_path`
if [ "$test_log" == "" ]; then
	test_log=`nv get path_log`"te.log"
fi

c_id=$1
path_conf=`nv get path_conf`
path_tmp=`nv get path_tmp`
dhcp6s_conf=$path_conf/dhcp6s$c_id.conf
radvd_conf=$path_conf/radvd$c_id.conf
ndp_log=$path_conf/ndp$c_id.log
radvd_pidfile=$path_tmp/radvd$c_id.pid

ps_if=`nv get pswan`$c_id
eth_if=`nv get "ps_ext"$c_id`
br_if="br"$c_id

echo "Info: psext_updown_ipv6.sh $ps_if $eth_if $br_if start" >> $test_log

prefix_len=`nv get $ps_if"_ipv6_prefix_len"`
br_ip=`nv get $br_if"_ipv6_ip"`
ps_ip=`nv get $ps_if"_ipv6_ip"`
pdp_ip=`nv get $ps_if"_ipv6_pdp"`
local_ipv6_addr=`nv get $ps_if"_ipv6_local"`

linkup_get_addr()
{
    echo 0 > /proc/sys/net/ipv6/conf/all/forwarding
    echo 0 > /proc/sys/net/ipv6/conf/$ps_if/accept_ra
    echo 0 > /proc/sys/net/ipv6/conf/$eth_if/accept_ra
    echo 0 > /proc/sys/net/ipv6/conf/$br_if/accept_ra
    ifconfig $ps_if up 2>>$test_log
	if [ $? -ne 0 ];then
	    echo "Error: ifconfig $ps_if up failed." >> $test_log
    fi
	ip -6 addr add $local_ipv6_addr/64 dev $ps_if 2>>$test_log
	brctl addbr $br_if
	brctl setfd $br_if 0.1
	ifconfig $br_if up 2>>$test_log
	if [ $? -ne 0 ];then
		echo "Error: ifconfig $br_if up failed." >> $test_log
	fi
	ip -6 addr add $br_ip/64 dev $br_if 
	ip -6 addr add $ps_ip/126 dev $ps_if 2>>$test_log
	if [ $? -ne 0 ];then
		echo "Error: ip -6 addr add $ps_ip/126 dev $ps_if failed." >> $test_log
	fi
	nv set $ps_if"_ipv6_state"="working"	
}

linkup_route_set()
{
    echo 0 > /proc/sys/net/ipv6/conf/all/forwarding 

    marknum=`expr $c_id + 60`
    ip6tables -t mangle -A PREROUTING -i $ps_if -j MARK --set-mark $marknum
    rt_num=`expr $c_id + 160`
    ip -6 route add default dev $br_if table $rt_num 	
    ip -6 rule add to $pdp_ip/64 fwmark $marknum table $rt_num

    marknum=`expr $c_id + 50`
    ip6tables -t mangle -A PREROUTING -i $br_if -j MARK --set-mark $marknum
    rt_num=`expr $c_id + 150`
    ip -6 route add default dev $ps_if table $rt_num
    ip -6 rule add from $pdp_ip/64 fwmark $marknum table $rt_num

    ip6tables -t filter -A FORWARD -p icmpv6 --icmpv6-type 135 -j DROP

    ip -6 route flush cache

    echo "Info: route_set ps_ip=$ps_ip" >> $test_log
    ip -6 route add default dev $ps_if 2>>$test_log
    if [ $? -ne 0 ];then
	    echo "Error: ip -6 route add default dev $ps_if failed." >> $test_log
    fi

    echo 1 > /proc/sys/net/ipv6/conf/all/forwarding
    echo 1 > /proc/sys/net/ipv6/conf/$ps_if/accept_ra
    echo 1 > /proc/sys/net/ipv6/conf/$eth_if/accept_ra
    echo 1 > /proc/sys/net/ipv6/conf/$br_if/accept_ra
    echo 1 > /proc/sys/net/ipv6/conf/all/proxy_ndp

    zte_ndp -a -s $br_if -d $ps_if -l $ndp_log -p &
}

linkup_dhcpv6_set()
{
	dhcp6s -dDf -c $dhcp6s_conf $br_if &
}

linkup_radvd_set() 
{
	radvd -d 3 -C $radvd_conf -p $radvd_pidfile &
}

mtu=`nv get mtu`
ifconfig $ps_if mtu $mtu
linkup_get_addr
linkup_route_set
linkup_dhcpv6_set
linkup_radvd_set
brctl addif $br_if $eth_if
ifconfig $eth_if up
tc_tbf.sh up $c_id
echo "Info: psext_up_ipv6.sh leave" >> $test_log
