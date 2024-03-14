#!/bin/sh

path_sh=`nv get path_sh`
. $path_sh/global.sh


c_id=$2

dhcp6s_conf=$path_conf/dhcp6s$c_id.conf
radvd_conf=$path_conf/radvd$c_id.conf
ndp_log=$path_conf/ndp$c_id.log
radvd_pidfile=$path_tmp/radvd$c_id.pid

ps_if=`nv get pswan`$c_id
eth_if=`nv get "ps_ext"$c_id`
ps_ext_mode=`nv get need_jilian`
br_if="br"$c_id
dnsconfig=0
prefix_len=64
echo "Info: psext_updown_ipv6.sh $ps_ext_mode $ps_if $eth_if $br_if start" >> $test_log

b_dhcpv6stateEnabled=`nv get dhcpv6stateEnabled`
b_dhcpv6statelessEnabled=`nv get dhcpv6statelessEnabled`


linkup_add_dns_to_dhcp6s_radvd_conf()
{
    ipv6_pridns_auto=`nv get $ps_if"_ipv6_pridns_auto"`
    ipv6_secdns_auto=`nv get $ps_if"_ipv6_secdns_auto"`

    if [ -n "$ipv6_pridns_auto" ] && [ "-$ipv6_pridns_auto" != "-::" ] && [ "-$ipv6_pridns_auto" != "-::0" ];then
        ipv6_prefer_dns=$ipv6_pridns_auto
    fi

    if [ -n "$ipv6_secdns_auto" ] && [ "-$ipv6_secdns_auto" != "-::" ] && [ "-$ipv6_secdns_auto" != "-::0" ];then
        ipv6_standby_dns=$ipv6_secdns_auto
    fi

    if [ "-$ipv6_prefer_dns" == "-" -a "-$ipv6_standby_dns" == "-" ]; then
        return
    else
        if [ -n "$1" ] && [ "-$1" == "-dhcp6s" ] ;then
            echo -e "\toption dns_servers $ipv6_prefer_dns $ipv6_standby_dns;" >> $dhcp6s_conf
        elif [ -n "$1" ] && [ "-$1" == "-radvd" ] ;then
            sed -i '$d' $radvd_conf
            echo -e "\tRDNSS $ipv6_prefer_dns $ipv6_standby_dns\n\t{" >> $radvd_conf
            echo -e "\t\tAdvRDNSSPreference 15;" >> $radvd_conf
            echo -e "\t\tAdvRDNSSOpen on;" >> $radvd_conf
            echo -e "\t};\n};" >> $radvd_conf
        fi

        if [ "-$dnsconfig" == "-0" ]; then
            echo "dnsconfig $1 $ipv6_prefer_dns, $ipv6_standby_dns" >> $test_log
            if [ "-$ipv6_prefer_dns" != "-" ]; then
                echo "nameserver $ipv6_prefer_dns" >> /etc/resolv.conf
            fi
            if [ "-$ipv6_standby_dns" != "-" ]; then
                echo "nameserver $ipv6_standby_dns" >> /etc/resolv.conf
            fi
            dnsconfig=1
        fi
    fi
}

linkup_dhcpv6_set()
{
    dhcpv6_start=$pdp_ip
    dhcpv6_end=$pdp_ip

    gw=`nv get $ps_if"_ipv6_gw"`

    echo -e "interface $br_if {" > $dhcp6s_conf
    if [ "-$b_dhcpv6stateEnabled" = "-1" ];then
        echo -e "\tserver-preference 255;\n\trenew-time 6000;" >> $dhcp6s_conf
        echo -e "\trebind-time 9000;\n\tprefer-life-time 1300;" >> $dhcp6s_conf
        echo -e "\tvalid-life-time 2000;\n\tallow rapid-commit;" >> $dhcp6s_conf
        echo -e "\tlink $br_if {\n\t\tallow unicast;\n\t\tsend unicast;" >> $dhcp6s_conf
        echo -e "\t\tpool {\n\t\t\trange $dhcpv6_start to $dhcpv6_end/$prefix_len;" >> $dhcp6s_conf
        echo -e "\t\t};\n\t};" >> $dhcp6s_conf
        linkup_add_dns_to_dhcp6s_radvd_conf dhcp6s
        echo -e "};" >> $dhcp6s_conf
        dhcp6s -dDf -c $dhcp6s_conf $br_if &
    else
        if [ "-$b_dhcpv6statelessEnabled" = "-1" ];then
            echo -e "\tlink $br_if {\n\t};" >> $dhcp6s_conf
            linkup_add_dns_to_dhcp6s_radvd_conf dhcp6s
            echo -e "};" >> $dhcp6s_conf
            dhcp6s -dDf -c $dhcp6s_conf $br_if &
			if [ $? -ne 0 ];then
                echo "Error: dhcp6s -dDf -c $dhcp6s_conf $br_if failed." >> $test_log
            fi
        fi
    fi
}

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
	prefix_info_temp=`nv get $ps_if"_ipv6_prefix_info"`
	if [ -n "$prefix_info_temp" -a "-$prefix_info_temp" != "-::" ]; then
		ret_code=0
	else
		sleep 1
		interface_id_temp1=`nv get $ps_if"_ipv6_interface_id"`
		local_ipv6_addr="fe80::"$interface_id_temp1
		local_ipv6_addr_nv="$ps_if""_local_ipv6_addr"
		nv set $local_ipv6_addr_nv=$local_ipv6_addr
		ip -6 addr add $local_ipv6_addr/64 dev $ps_if 2>>$test_log
		zte_ipv6_slaac -i "$ps_if" 
		ret_code=$?
	fi
    echo "Info: zte_ipv6_slaac return: $ret_code" >> $test_log
    echo "the program zte_ipv6_slaac return  = $ret_code"
    if [ $ret_code -eq 0 ]; then
        echo "the zte_ipv6_slaac success"
        interface_id_temp=`nv get $ps_if"_ipv6_interface_id"`
        prefix_info_temp=`nv get $ps_if"_ipv6_prefix_info"`
        prefix_len=`nv get $ps_if"_ipv6_prefix_len"`
        echo "##############1##########"
        echo "$interface_id_temp"
        echo "$prefix_info_temp $prefix_len"
        echo "##############2##########"

        pdp_ip=$prefix_info_temp$interface_id_temp
        nv set ipv6_wan_ipaddr="$pdp_ip"

        ipv6_addr_conver $pdp_ip "$ps_if"

        br_ip=`nv get ipv6_br0_addr`
        brctl addbr $br_if
        brctl setfd $br_if 0.1
        nv set $br_if"_ipv6_ip"=$br_ip
        ifconfig $br_if up 2>>$test_log
		if [ $? -ne 0 ];then
            echo "Error: ifconfig $br_if up failed." >> $test_log
        fi
        ip -6 addr add $br_ip/64 dev $br_if 
        ps_ip=`nv get $ps_if"_dhcpv6_start"`
        nv set $ps_if"_ipv6_ip"=$ps_ip
        ip -6 addr add $ps_ip/126 dev $ps_if 2>>$test_log
		if [ $? -ne 0 ];then
	        echo "Error: ip -6 addr add $ps_ip/126 dev $ps_if failed." >> $test_log
        fi
		nv set $ps_if"_ipv6_state"="working"

        echo "Info: zte_ipv6_slaac pdp_ip: $pdp_ip" >> $test_log
        echo "Info: zte_ipv6_slaac ps_ip: $ps_ip" >> $test_log
        echo "Info: zte_ipv6_slaac br_ip: $br_ip" >> $test_log
    else
        echo "the zte_ipv6_slaac fail"
		nv set $ps_if"_ipv6_state"="dead"
        exit 1
    fi
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

    ndp_kill
    zte_ndp -a -s $br_if -d $ps_if -l $ndp_log -p &
}

linkup_radvd_set() 
{
    echo "enter linkup_radvd_set "

    rm -rf $radvd_conf

    if [ "-$b_dhcpv6stateEnabled" = "-1" ];then
        echo -e "interface $br_if\n{\n\tAdvSendAdvert on;" > $radvd_conf
        echo -e "\tAdvManagedFlag on;\n};" >> $radvd_conf
        radvd_kill
		rm -rf $radvd_pidfile
        radvd -d 3 -C $radvd_conf -p $radvd_pidfile&
        echo  "leave linkup_radvd_set "
        return
    fi

    echo "Info: psext_updown_ipv6.sh br_if:$br_if, prefix_len:$prefix_len" >> $test_log
    echo "ipv6_br0_addr_tmp:$ipv6_br0_addr_tmp"
    echo "prefix_len:$prefix_len"

    cp $path_ro/radvd_template.conf $radvd_conf

	sed  -i -e 's/#ipv6_wan_addr#\/64/#ipv6_wan_addr#\/#prefix_len#/g' $radvd_conf
    sed  -i -e s/br0/$br_if/g $radvd_conf
    sed  -i -e s/#ipv6_wan_addr#/$br_ip/g $radvd_conf 
    sed  -i -e s/#prefix_len#/$prefix_len/g $radvd_conf
    sed  -i -e s/#adv_switch#/on/g $radvd_conf 


    if [ "-$b_dhcpv6statelessEnabled" = "-1" ];then
        echo "use dhcpv6stateless for dns"
    else
        sed -i -e 's/AdvOtherConfigFlag on;/AdvOtherConfigFlag off;/g' $radvd_conf
        linkup_add_dns_to_dhcp6s_radvd_conf radvd
    fi

    radvd_kill
    sleep 1
	rm -rf $radvd_pidfile
    radvd -d 3 -C $radvd_conf -p $radvd_pidfile &

    echo  "leave linkup_radvd_set "
}

br_up()
{
    br="br"$c_id
    brctl addbr $br 2>>$test_log
	if [ $? -ne 0 ];then
	    echo "Error: brctl addbr $br failed." >> $test_log
    fi
    brctl setfd $br 0.1 2>>$test_log
	if [ $? -ne 0 ];then
	    echo "Error: brctl setfd $br 0.1 failed." >> $test_log
    fi
    ifconfig $br up 2>>$test_log
	if [ $? -ne 0 ];then
	    echo "Error: ifconfig $br up failed." >> $test_log
    fi

    ifconfig $ps_if up 2>>$test_log
	if [ $? -ne 0 ];then
	    echo "Error: ifconfig $ps_if up failed." >> $test_log
    fi
    brctl addif $br $ps_if 2>>$test_log
	if [ $? -ne 0 ];then
	    echo "Error: brctl addif $br $ps_if failed." >> $test_log
    fi

    brctl addif $br $eth_if 2>>$test_log
	if [ $? -ne 0 ];then
	    echo "Error: brctl addif $br $eth_if failed." >> $test_log
    fi
    ifconfig $eth_if up 2>>$test_log
	if [ $? -ne 0 ];then
	    echo "Error: ifconfig $eth_if up failed." >> $test_log
    fi
}

br_down()
{
    br="br"$c_id
    brctl delif $br $eth_if 2>>$test_log
	if [ $? -ne 0 ];then
	    echo "Error: brctl delif $br $eth_if failed." >> $test_log
    fi
    ifconfig $eth_if down 2>>$test_log
	if [ $? -ne 0 ];then
	    echo "Error: ifconfig $eth_if down failed." >> $test_log
    fi
    brctl delif $br $ps_if 2>>$test_log
	if [ $? -ne 0 ];then
	    echo "Error: brctl delif $br $ps_if failed." >> $test_log
    fi
    ifconfig $ps_if down 2>>$test_log
	if [ $? -ne 0 ];then
	    echo "Error: ifconfig $ps_if down failed." >> $test_log
    fi
    ifconfig $br down 2>>$test_log
	if [ $? -ne 0 ];then
	    echo "Error: ifconfig $br down failed." >> $test_log
    fi
    brctl delbr $br 2>>$test_log
	if [ $? -ne 0 ];then
	    echo "Error: brctl delbr $br failed." >> $test_log
    fi
}

linkdown_radvd_set()
{
    radvd_kill
}

linkdown_dhcpv6_server_set()
{
    dhcp6s_kill
}

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

    ndp_kill
}

if [ "$1" == "linkup" ]; then
	mtu=`nv get mtu`
	ifconfig $ps_if mtu $mtu
    if [ "-$ps_ext_mode" == "-1" ]; then
        linkup_get_addr
        linkup_route_set
        linkup_dhcpv6_set
        linkup_radvd_set
        brctl addif $br_if $eth_if
		ifconfig $eth_if up
		tc_tbf.sh up $c_id
    elif [ "-$ps_ext_mode" == "-0" ]; then
        br_up
    fi
elif [ "$1" == "linkdown" ]; then
    if [ "-$ps_ext_mode" == "-1" ]; then
        tc_tbf.sh down $c_id
        linkdown_radvd_set
        linkdown_dhcpv6_server_set
        linkdown_route_set
        slaac_kill
        brctl delif $br_if $eth_if
        ifconfig $eth_if down
        echo "" > /etc/resolv.conf
    elif [ "-$ps_ext_mode" == "-0" ]; then
        br_down
    fi
fi

echo "Info: psext_updown_ipv6.sh leave" >> $test_log
