#!/bin/sh
test_log=`nv get telog_path`
if [ "$test_log" == "" ]; then
	test_log=`nv get path_log`"te.log"
fi
echo "Info: psext_updown_ipv6.sh $ps_if $eth_if $br_if start" >> $test_log

c_id=$1
ps_if=`nv get pswan`$c_id
eth_if=`nv get "ps_ext"$c_id`
br_if="br"$c_id

linkdown_route_set()
{
    br_ip=`nv get $br_if"_ipv6_ip"`
    ps_ip=`nv get $ps_if"_ipv6_ip"`
    pdp_ip=`nv get ipv6_wan_ipaddr`

    ip6tables -t filter -D FORWARD -p icmpv6 --icmpv6-type 135 -j DROP

    marknum=`expr $c_id + 50`
    rt_num=`expr $c_id + 150`
    ip -6 rule del from $pdp_ip/64 fwmark $marknum table $rt_num
    ip6tables -t mangle -D PREROUTING -i $br_if -j MARK --set-mark $marknum
    ip -6 route del default dev $ps_if table $rt_num

    marknum=`expr $c_id + 60`
    rt_num=`expr $c_id + 160`
    ip -6 rule del to $pdp_ip/64 fwmark $marknum table $rt_num
    ip6tables -t mangle -D PREROUTING -i $ps_if -j MARK --set-mark $marknum
    ip -6 route del default dev $br_if table $rt_num

    ip -6 addr del $br_ip/126 dev $br_if
    ip -6 addr del $ps_ip/126 dev $ps_if
    ip -6 route del default

    ifconfig $br_if down 2>>$test_log
	if [ $? -ne 0 ];then
        echo "Error: ifconfig $br_if down failed." >> $test_log
    fi
    ifconfig $ps_if down 2>>$test_log
	if [ $? -ne 0 ];then
	    echo "Error: ifconfig $ps_if down failed." >> $test_log
    fi

    echo 0 > /proc/sys/net/ipv6/conf/$ps_if/accept_ra

    nv set $br_if"_ipv6_ip"="::"
    nv set $ps_if"_ipv6_ip"="::"
    nv set $ps_if"_ipv6_pridns_auto"="::"
    nv set $ps_if"_ipv6_secdns_auto"="::"
    nv set $ps_if"_ipv6_gw"="::"
    nv set $ps_if"_ipv6_interface_id"="::"
    nv set $ps_if"_ipv6_prefix_info"="::"
    nv set $ps_if"_dhcpv6_start"="::"
    nv set $ps_if"_dhcpv6_end"="::"

    nv set ipv6_wan_ipaddr="::"
	nv set $ps_if"_ipv6_state"="dead"

	local_ipv6_addr_nv="$ps_if""_local_ipv6_addr"
	nv set $local_ipv6_addr_nv="::"

}

tc_tbf.sh down $c_id
linkdown_route_set
brctl delif $br_if $eth_if
ifconfig $eth_if down
echo "Info: psext_down_ipv6.sh leave" >> $test_log
