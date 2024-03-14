#!/bin/sh

path_sh=`nv get path_sh`
. $path_sh/global.sh

echo "Info: ppp_updown.sh $1 $2 start" >> $test_log

echo 1 > /proc/sys/net/ipv4/ip_forward

path_sh=`nv get path_sh`
path_conf=`nv get path_conf`
c_id=$2

ps_if=`nv get pswan`$c_id
eth_if=`nv get ppp_name`
pdp_type=`nv get ppp_pdp_type`

dhcp6s_conf=$path_conf/dhcp6s$c_id.conf
radvd_conf=$path_conf/radvd$c_id.conf
ndp_log=$path_conf/ndp$c_id.log
radvd_pidfile=$path_tmp/radvd$c_id.pid

dnsconfig=0

b_dhcpv6stateEnabled=`nv get dhcpv6stateEnabled`
b_dhcpv6statelessEnabled=`nv get dhcpv6statelessEnabled`

ipaddr_set()
{
    pdp_ip=`nv get $ps_if"_ip"`
	ps_ip_abc=${pdp_ip%.*}
	ps_ip_ab=${ps_ip_abc%.*}
	ps_ip_c=${ps_ip_abc##*.}
	ps_ip_d=${pdp_ip##*.}  

	[ "$ps_ip_c" -ge "254" ] && { ps_ip_c="250"; }
	[ "$ps_ip_c" -le "2" ] && { ps_ip_c="10"; }
	ps_ip_c1=`expr $ps_ip_c + 1`
	ps_ip_c2=`expr $ps_ip_c - 1`

	ps_ip=$ps_ip_ab"."$ps_ip_c1"."$ps_ip_d

	ifconfig $ps_if $ps_ip up
	if [ $? -ne 0 ];then
	    echo "Error: ifconfig $ps_if $ps_ip up failed." >> $test_log
    fi
	echo "Info: ifconfig $ps_if $ps_ip gw $ps_ip up" >> $test_log

	eth_ip=$ps_ip_ab"."$ps_ip_c2"."$ps_ip_d


	nv set $eth_if"_ip"=$eth_ip
	ifconfig $eth_if $eth_ip
	if [ $? -ne 0 ];then
	    echo "Error: ifconfig $eth_if $eth_ip up failed." >> $test_log
    fi
	echo "Info: ifconfig $eth_if $eth_ip up" >> $test_log
}

route_set()
{
    marknum=`expr $c_id + 20`
    iptables -t mangle -A PREROUTING -i $ps_if -j MARK --set-mark $marknum
	rt_num=`expr $c_id + 120`

    echo "Info: ip route add default dev $eth_if table $rt_num " >> $test_log	
    ip route add default dev $eth_if table $rt_num 	

	echo "Info: ip rule add to $pdp_ip fwmark $marknum table $rt_num " >> $test_log
	ip rule add to $pdp_ip fwmark $marknum table $rt_num

	marknum=`expr $c_id + 10`
    iptables -t mangle -A PREROUTING -i $eth_if -d ! $eth_ip/24 -j MARK --set-mark $marknum
	rt_num=`expr $c_id + 100`

	echo "Info: ip route add default dev $ps_if table $rt_num " >> $test_log
    ip route add default dev $ps_if table $rt_num

	echo "Info: ip rule add from $pdp_ip fwmark $marknum table $rt_num " >> $test_log
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

route_del()
{
    pdp_ip=`nv get $ps_if"_ip"`

	eth_ip=`nv get $eth_if"_ip"`


	marknum=`expr $c_id + 10`
	rt_num=`expr $c_id + 100`

	iptables -t mangle -D PREROUTING -i $eth_if -d ! $eth_ip/24 -j MARK --set-mark $marknum
	ip rule del from $pdp_ip fwmark $marknum table $rt_num 
    ip route del default dev $ps_if table $rt_num

    marknum=`expr $c_id + 20`
	rt_num=`expr $c_id + 120`
    iptables -t mangle -D PREROUTING -i $ps_if -j MARK --set-mark $marknum
	ip rule del to $pdp_ip fwmark $marknum table $rt_num
    ip route del default dev $eth_if table $rt_num 

	ifconfig $ps_if down
	if [ $? -ne 0 ];then
	    echo "Error: ifconfig $ps_if down failed." >> $test_log
    fi

	nv set ppp_cid=""
    nv set $eth_if"_ip"=0.0.0.0
    nv set $eth_if"_nm"=0.0.0.0
    nv set $ps_if"_ip"=0.0.0.0
    nv set $ps_if"_pridns"=0.0.0.0
    nv set $ps_if"_secdns"=0.0.0.0
}

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

    echo -e "interface $eth_if {" > $dhcp6s_conf
    if [ "-$b_dhcpv6stateEnabled" = "-1" ];then
        echo -e "\tserver-preference 255;\n\trenew-time 6000;" >> $dhcp6s_conf
        echo -e "\trebind-time 9000;\n\tprefer-life-time 1300;" >> $dhcp6s_conf
        echo -e "\tvalid-life-time 2000;\n\tallow rapid-commit;" >> $dhcp6s_conf
        echo -e "\tlink $eth_if {\n\t\tallow unicast;\n\t\tsend unicast;" >> $dhcp6s_conf
        echo -e "\t\tpool {\n\t\t\trange $dhcpv6_start to $dhcpv6_end/$prefix_len;" >> $dhcp6s_conf
        echo -e "\t\t};\n\t};" >> $dhcp6s_conf
        linkup_add_dns_to_dhcp6s_radvd_conf dhcp6s
        echo -e "};" >> $dhcp6s_conf
        dhcp6s -dDf -c $dhcp6s_conf $eth_if &
    else
        if [ "-$b_dhcpv6statelessEnabled" = "-1" ];then
            echo -e "\tlink $eth_if {\n\t};" >> $dhcp6s_conf
            linkup_add_dns_to_dhcp6s_radvd_conf dhcp6s
            echo -e "};" >> $dhcp6s_conf
            dhcp6s -dDf -c $dhcp6s_conf $eth_if &
			if [ $? -ne 0 ];then
                echo "Error: dhcp6s -dDf -c $dhcp6s_conf $eth_if failed." >> $test_log
            fi
        fi
    fi
}

ip6addr_set()
{
    echo 0 > /proc/sys/net/ipv6/conf/all/forwarding
    echo 0 > /proc/sys/net/ipv6/conf/$ps_if/accept_ra
    echo 0 > /proc/sys/net/ipv6/conf/$eth_if/accept_ra

    ifconfig $ps_if up 2>>$test_log
	if [ $? -ne 0 ];then
	    echo "Error: ifconfig $ps_if up failed." >> $test_log
    fi
    sleep 1
		interface_id_temp1=`nv get $ps_if"_ipv6_interface_id"`
		local_ipv6_addr="fe80::"$interface_id_temp1
		local_ipv6_addr_nv="$ps_if""_local_ipv6_addr"
		nv set $local_ipv6_addr_nv=$local_ipv6_addr
		ip -6 addr add $local_ipv6_addr/64 dev $ps_if 2>>$test_log
    zte_ipv6_slaac -i "$ps_if" 
    ret_code=$?

    echo "Info: zte_ipv6_slaac return: $ret_code" >> $test_log
    echo "the program zte_ipv6_slaac return  = $ret_code"
    if [ $ret_code -eq 0 ]; then
        echo "the zte_ipv6_slaac success"
        interface_id_temp=`nv get $ps_if"_ipv6_interface_id"`
        prefix_info_temp=`nv get $ps_if"_ipv6_prefix_info"`

        echo "##############1##########"
        echo "$interface_id_temp"
        echo "$prefix_info_temp"
        echo "##############2##########"

        pdp_ip6=$prefix_info_temp$interface_id_temp
        nv set ipv6_wan_ipaddr="$pdp_ip6"

        ipv6_addr_conver $pdp_ip6 "$ps_if"

        eth_ip6=`nv get ipv6_br0_addr`

        ip -6 addr add $eth_ip6/64 dev $eth_if 
		if [ $? -ne 0 ];then
	        echo "Error: ip -6 addr add $eth_ip6/64 dev $eth_if failed." >> $test_log
        fi
        ps_ip6=`nv get $ps_if"_dhcpv6_start"`
        nv set $ps_if"_ipv6_ip"=$ps_ip6
        ip -6 addr add $ps_ip6/126 dev $ps_if 2>>$test_log
		if [ $? -ne 0 ];then
	        echo "Error: ip -6 addr add $ps_ip6/126 dev $ps_if failed." >> $test_log
        fi
		nv set $ps_if"_ipv6_state"="working"

        echo "Info: zte_ipv6_slaac pdp_ip6: $pdp_ip6" >> $test_log
        echo "Info: zte_ipv6_slaac ps_ip6: $ps_ip6" >> $test_log
        echo "Info: zte_ipv6_slaac eth_ip6: $eth_ip6" >> $test_log
    else
        echo "the zte_ipv6_slaac fail"
		nv set $ps_if"_ipv6_state"="dead"
        exit 1
    fi
}

route6_set()	
{
	echo 0 > /proc/sys/net/ipv6/conf/all/forwarding 

    marknum=`expr $c_id + 60`
    ip6tables -t mangle -A PREROUTING -i $ps_if -j MARK --set-mark $marknum
    rt_num=`expr $c_id + 160`
    ip -6 route add default dev $eth_if table $rt_num
    ip -6 rule add to $pdp_ip6/64 fwmark $marknum table $rt_num

    marknum=`expr $c_id + 50`
    ip6tables -t mangle -A PREROUTING -i $eth_if -j MARK --set-mark $marknum
    rt_num=`expr $c_id + 150`
    ip -6 route add default dev $ps_if table $rt_num
    ip -6 rule add from $pdp_ip6/64 fwmark $marknum table $rt_num

    ip6tables -t filter -A FORWARD -p icmpv6 --icmpv6-type 135 -j DROP

    ip -6 route flush cache

    echo "Info: route6_set pdp_ip6=$pdp_ip6" >> $test_log

    ip -6 route add default dev $ps_if 2>>$test_log
    if [ $? -ne 0 ];then
	    echo "Error: ip -6 route add default dev $ps_if failed." >> $test_log
    fi

    echo 1 > /proc/sys/net/ipv6/conf/all/forwarding
    echo 1 > /proc/sys/net/ipv6/conf/$ps_if/accept_ra
    echo 1 > /proc/sys/net/ipv6/conf/$eth_if/accept_ra
    echo 1 > /proc/sys/net/ipv6/conf/all/proxy_ndp

    ndp_kill
    zte_ndp -a -s $eth_if -d $ps_if -l $ndp_log -p &
}

linkup_radvd_set() 
{
    echo "enter linkup_radvd_set "

    prefix_len=64

    rm -rf $radvd_conf

    if [ "-$b_dhcpv6stateEnabled" = "-1" ];then
        echo -e "interface $eth_if\n{\n\tAdvSendAdvert on;" > $radvd_conf
        echo -e "\tAdvManagedFlag on;\n};" >> $radvd_conf
        radvd_kill
		rm -rf $radvd_pidfile
        radvd -d 3 -C $radvd_conf -p $radvd_pidfile&
        echo  "leave linkup_radvd_set "
        return
    fi

    echo "Info: psext_updown_ipv6.sh eth_if:$eth_if, prefix_len:$prefix_len" >> $test_log
    echo "prefix_len:$prefix_len"

    cp $path_ro/radvd_template.conf $radvd_conf

	sed  -i -e 's/#ipv6_wan_addr#\/64/#ipv6_wan_addr#\/#prefix_len#/g' $radvd_conf
    sed  -i -e s/br0/$eth_if/g $radvd_conf
    sed  -i -e s/#ipv6_wan_addr#/$eth_ip6/g $radvd_conf 
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

linkdown_radvd_set()
{
    radvd_kill
}

linkdown_dhcpv6_server_set()
{
    dhcp6s_kill
}

route6_del()
{
    eth_ip6=`nv get ipv6_br0_addr`
    ps_ip6=`nv get $ps_if"_ipv6_ip"`
    pdp_ip6=`nv get ipv6_wan_ipaddr`

    ip6tables -t filter -D FORWARD -p icmpv6 --icmpv6-type 135 -j DROP

    marknum=`expr $c_id + 50`
    rt_num=`expr $c_id + 150`
    ip -6 rule del from $pdp_ip6/64 fwmark $marknum table $rt_num
    ip6tables -t mangle -D PREROUTING -i $eth_if -j MARK --set-mark $marknum
    ip -6 route del default dev $ps_if table $rt_num

    marknum=`expr $c_id + 60`
    rt_num=`expr $c_id + 160`
    ip -6 rule del to $pdp_ip6/64 fwmark $marknum table $rt_num
    ip6tables -t mangle -D PREROUTING -i $ps_if -j MARK --set-mark $marknum
    ip -6 route del default dev $eth_if table $rt_num

    ip -6 addr del $eth_ip6/64 dev $eth_if
    ip -6 addr del $ps_ip6/126 dev $ps_if
    ip -6 route del default

    ifconfig $eth_if down 2>>$test_log
    ifconfig $ps_if down 2>>$test_log
	if [ $? -ne 0 ];then
	    echo "Error: ifconfig $ps_if down failed." >> $test_log
    fi

    echo 0 > /proc/sys/net/ipv6/conf/$ps_if/accept_ra

    nv set ppp_cid=""
    nv set $ps_if"_pppv6_ip"="::"
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
	if [ "$pdp_type" != "IPV6" ]; then
		ipaddr_set
		route_set
	fi
	if [ "$pdp_type" == "IPV6" -o "$pdp_type" == "IPV4V6" ]; then
		ip6addr_set
		route6_set
		linkup_dhcpv6_set
		linkup_radvd_set
	fi
elif [ "$1" == "linkdown" ]; then
	if [ "$pdp_type" != "IPV6" ]; then		
	    route_del
	fi	
	if [ "$pdp_type" == "IPV6" -o "$pdp_type" == "IPV4V6" ]; then 	
		linkdown_radvd_set
		linkdown_dhcpv6_server_set
		route6_del
		slaac_kill
		echo "" > /etc/resolv.conf
	fi
fi

echo "Info: ppp_updown.sh $1 $2 leave" >> $test_log
