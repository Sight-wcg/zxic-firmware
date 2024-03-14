#!/bin/sh 

path_sh=`nv get path_sh`
. $path_sh/global.sh


echo "input param is $1 $2 $3"
echo "Info: wan_ipv6 $1 $2 $3 start" >> $test_log

if [ "$3" == "" ]; then
    c_id="0"
else
    c_id=$3
fi
def_cid=`nv get default_cid`

is_chinamobile_pd_diff=`nv get pd_chinamobile_enable`
pd_chinamobile=`nv get pd_chinamobile`
prefix_len=`nv get pd_len_chinamobile`

b_dhcpv6stateEnabled=`nv get dhcpv6stateEnabled`
b_dhcpv6statelessEnabled=`nv get dhcpv6statelessEnabled`

get_wan_info() 
{
    echo "wan_name_info = $1"

    wan_mode=`nv get $1"_mode"`

    case $1 in 
    "pswan")
        wan_if=$pswan_name$2 ;;
    "usbwan")
        wan_if=$usbwan_if ;;
    "ethwan")
        wan_if=$ethwan_if ;;
    "wifiwan")
        wan_if=$wifiwan_if ;;
    esac
    mtu=`nv get mtu`
    ifconfig $wan_if mtu $mtu

    dhcp6s_conf=$path_conf/dhcp6s_$wan_if.conf
    radvd_conf=$path_conf/radvd_$wan_if.conf
	radvd_pidfile=$path_tmp/radvd_$wan_if.pid
    ndp_log=$path_conf/ndp_$wan_if.log

    dosenable=`nv get dosenable`
    if [ "x$dosenable" != "x0" ]; then
        if [ "$1" == "pswan" ]; then
            wan6_prefix=$1$2"_prefix"
        else
            wan6_prefix=$1"_prefix"
        fi
        echo 1 > /sys/module/fast_common/parameters/lan_dos_enable
        echo "wan6_prefix_name = $wan6_prefix"
    fi

    echo "wan_if_info = $wan_if"
}

slaac_kill()
{
	ps > ${path_tmp}/zte_ipv6_slaac.${wan_if}.$$
	slaac_pid=`awk 'BEGIN{temp1="'"${wan_if}"'";temp2="zte_ipv6_slaac"}{if(index($0,temp1)>0 && index($0,temp2)>0){print $1}}' ${path_tmp}/zte_ipv6_slaac.${wan_if}.$$`
	rm -f ${path_tmp}/zte_ipv6_slaac.${wan_if}.$$
    [ -n "$slaac_pid" ] && { kill $slaac_pid; echo "Info: kill slaac $slaac_pid " >> $test_log ; }
}

linkup_get_wan_addr()
{
    echo "wan_name_info = $wan_if"

    echo 0 > /proc/sys/net/ipv6/conf/$wan_if/accept_ra

	if [ "$1" == "pswan" ]; then

		if [ "-$wan_mode" == "-dhcp" ]; then
		    ifconfig $wan_if arp 2>>$test_log
			if [ $? -ne 0 ];then
	            echo "Error: ifconfig $wan_if arp failed." >> $test_log
            fi
		fi
		ifconfig $wan_if up 2>>$test_log
		if [ $? -ne 0 ];then
	        echo "Error: ifconfig $wan_if up failed." >> $test_log
        fi
		prefix_info_temp=`nv get $wan_if"_ipv6_prefix_info"`
		if [ -n "$prefix_info_temp" -a "-$prefix_info_temp" != "-::" ]; then
			ret_code=0
		else
			sleep 1
			interface_id_temp1=`nv get $wan_if"_ipv6_interface_id"`
			local_ipv6_addr="fe80::"$interface_id_temp1
			local_ipv6_addr_nv="$wan_if""_local_ipv6_addr"
			nv set $local_ipv6_addr_nv=$local_ipv6_addr
			ip -6 addr add $local_ipv6_addr/64 dev $wan_if 2>>$test_log
			zte_ipv6_slaac -i "$wan_if" 
			ret_code=$?
		fi

		echo "the program zte_ipv6_slaac return  = $ret_code"
		if [ $ret_code -eq 0 ]; then
			echo "the zte_ipv6_slaac success"
			interface_id_temp=`nv get $wan_if"_ipv6_interface_id"`
			prefix_info_temp=`nv get $wan_if"_ipv6_prefix_info"`

			echo "##############1##########"
			echo "$interface_id_temp"
			echo "$prefix_info_temp"
			echo "##############2##########"            

			if [ "x$dosenable" != "x0" ]; then
				ip6_prefix=`echo "$prefix_info_temp" | awk -F ':' '{printf "0x"$1",0x"$2",0x"$3",0x"$4}'`
				echo "ip6_prefix1=$ip6_prefix"
				echo $ip6_prefix > /sys/module/fast_common/parameters/$wan6_prefix
			fi


			wan_addr=$prefix_info_temp$interface_id_temp
			wan_addr_nv=$wan_if"_ipv6_ip"
			nv set $wan_addr_nv="$wan_addr"
			echo "wan_addr = $wan_addr"

			ip -6 addr add $wan_addr/126 dev $wan_if 2>>$test_log
			if [ $? -ne 0 ];then
	            echo "Error: ip -6 addr add $wan_addr/126 dev $wan_if failed." >> $test_log
            fi

			killall -9 clatd
			clatd -i $wan_if -p 1:1:1:123:: &

			if [ "-$c_id" != "-$def_cid" ]; then
				wan_pri=`nv get $1"_priority"`
				rt_num=`expr $wan_pri \* 10 + $c_id`
				default_gw_addr_temp=`nv get $wan_if"_ipv6_gw"`
				echo "ipv6_wan_default_gw = $default_gw_addr_temp"
				ip -6 rule add from $wan_addr table $rt_num 2>>$test_log
				if [ $? -ne 0 ];then
	                echo "Error: ip -6 rule add from $wan_addr table $rt_num failed." >> $test_log
                fi
				if [ -n "$default_gw_addr_temp" -a "-$default_gw_addr_temp" != "-::" ] ; then
					ip -6 route add default via $default_gw_addr_temp dev $wan_if table $rt_num 2>>$test_log
					if [ $? -ne 0 ];then
	                    echo "Error: ip -6 route add default via $default_gw_addr_temp dev $wan_if table $rt_num failed." >> $test_log
                    fi
				else
					ip -6 route add default dev $wan_if table $rt_num 2>>$test_log
					if [ $? -ne 0 ];then
	                    echo "Error: ip -6 route add default dev $wan_if table $rt_num failed." >> $test_log
                    fi
				fi
				ip -6 route flush cache 2>>$test_log
				if [ $? -ne 0 ];then
	                echo "Error: ip -6 route flush cache failed." >> $test_log
                fi
			fi
			nv set $wan_if"_ipv6_state"="working"
		else
			echo "the zte_ipv6_slaac fail"
			nv set $wan_if"_ipv6_state"="dead"
		fi
	else	
		if [ "-$wan_mode" == "-DHCP" -o "-$wan_mode" == "-PPP" -o "-$wan_mode" == "-PPPOE"  ]; then 
			dhcp6c -dDf -z $wan_if &
		else
			ifconfig $wan_if up 2>>$test_log
			if [ $? -ne 0 ];then
	            echo "Error: ifconfig $wan_if up failed." >> $test_log
            fi
			interface_id_temp1=`nv get $wan_if"_ipv6_interface_id"`
			local_ipv6_addr="fe80::"$interface_id_temp1
			local_ipv6_addr_nv="$wan_if""_local_ipv6_addr"
			nv set $local_ipv6_addr_nv=$local_ipv6_addr
			ip -6 addr add $local_ipv6_addr/64 dev $wan_if 2>>$test_log

			zte_ipv6_slaac -i "$wan_if" 
			ret_code=$?

			echo "the program zte_ipv6_slaac return  = $ret_code"
			if [ $ret_code -eq 0 ]; then
				echo "the zte_ipv6_slaac success"
				interface_id_temp=`nv get $wan_if"_ipv6_interface_id"`
				prefix_info_temp=`nv get $wan_if"_ipv6_prefix_info"`

				echo "##############1##########"
				echo "$interface_id_temp"
				echo "$prefix_info_temp"
				echo "##############2##########"            

				if [ "x$dosenable" != "x0" ]; then
					ip6_prefix=`echo "$prefix_info_temp" | awk -F ':' '{printf "0x"$1",0x"$2",0x"$3",0x"$4}'`
					echo "ip6_prefix2=$ip6_prefix"
					echo $ip6_prefix > /sys/module/fast_common/parameters/$wan6_prefix
				fi

				wan_addr=$prefix_info_temp$interface_id_temp
				wan_addr_nv=$wan_if"_ipv6_ip"
				nv set $wan_addr_nv="$wan_addr"
				echo "wan_addr = $wan_addr"

				ip -6 addr add $wan_addr/126 dev $wan_if 2>>$test_log
				if [ $? -ne 0 ];then
	                echo "Error: ip -6 addr add $wan_addr/126 dev $wan_if failed." >> $test_log
                fi

				killall -9 clatd
				clatd -i $wan_if -p 1:1:1:123:: &
			else
				echo "the zte_ipv6_slaac fail"
			fi
		fi
	fi
}

linkdown_radvd_set() 
{
    if [ "-$b_dhcpv6stateEnabled" = "-1" ];then
        radvd_kill
        return
    else
        sed  -i -e s/AdvValidLifetime.*/'AdvValidLifetime 30;'/g $radvd_conf
        sed  -i -e s/AdvPreferredLifetime.*/'AdvPreferredLifetime 1;'/g $radvd_conf
    fi

    if [ "-$is_chinamobile_pd_diff" = "-1" ] ; then
        if [ "-$pd_chinamobile" == "-" ] ; then
            echo "no pd info get"
        else
            radvd_kill
			rm -rf $radvd_pidfile
            radvd -d 3 -C $radvd_conf -s -p $radvd_pidfile &
            nv set pd_chinamobile=""
            nv set pd_len_chinamobile=""
            radvd_kill
        fi
    fi

    radvd_kill
	rm -rf $radvd_pidfile
    radvd -d 3 -C $radvd_conf -s -p $radvd_pidfile &
}

linkdown_route_set()
{
    echo "wan_name_info = $wan_if"

    wan_addr=`nv get $wan_if"_ipv6_ip"`
	ip -6 addr del $wan_addr/126 dev $wan_if

	local_ipv6_addr_nv="$wan_if""_local_ipv6_addr"
	local_ipv6_addr=`nv get $local_ipv6_addr_nv`
	ip -6 addr del $local_ipv6_addr/64 dev $wan_if 2>>$test_log

	killall clatd
	sh $path_sh/clat_config.sh down $wan_if

	if [ "-$c_id" == "-0" -o "-$c_id" == "-$def_cid" ]; then
		echo 0 > /proc/sys/net/ipv6/conf/all/forwarding  
		ip -6 route del default

		nv set ipv6_br0_addr="::"
		ipv6_addr_conver $wan_addr "$wan_if"
		ipv6_br0_addr_tmp=`nv get ipv6_br0_addr`
		ip -6 addr del $ipv6_br0_addr_tmp/64 dev br0

		nv set ipv6_wan_ipaddr="::"

		def_cid=`nv get default_cid`
		if [ "-$c_id" == "-$def_cid" ]; then
			nv set default_cid=""
			nv set $wan_if"_ipv6_state"="dead"
		fi
	else
		wan_pri=`nv get $1"_priority"`
		rt_num=`expr $wan_pri \* 10 + $c_id`

		default_gw_addr_temp=`nv get $wan_if"_ipv6_gw"`
		echo "ipv6_wan_default_gw = $default_gw_addr_temp"

		ip -6 rule del from $wan_addr table $rt_num
		if [ -n "$default_gw_addr_temp" ] ; then
			ip -6 route del default via $default_gw_addr_temp dev $wan_if table $rt_num 
		else
			ip -6 route del default dev $wan_if table $rt_num 
		fi
		ip -6 route flush cache 2>>$test_log
		if [ $? -ne 0 ];then
	        echo "Error: ip -6 route flush cache failed." >> $test_log
        fi

		nv set $wan_if"_ipv6_state"="dead"

	fi

    echo 0 > /proc/sys/net/ipv6/conf/$wan_if/accept_ra

    nv set $wan_if"_ipv6_ip"="::"
    nv set $wan_if"_ipv6_pridns_auto"="::"
    nv set $wan_if"_ipv6_secdns_auto"="::"
    nv set $wan_if"_ipv6_gw"="::"
    nv set $wan_if"_ipv6_interface_id"="::"
    nv set $wan_if"_ipv6_prefix_info"="::"
    nv set $wan_if"_dhcpv6_start"="::"
    nv set $wan_if"_dhcpv6_end"="::"
    nv set $wan_if"_radvd_ipv6_dns_servers"="::"

	if [ "x$dosenable" != "x0" ]; then
		echo 0,0,0,0 > /sys/module/fast_common/parameters/$wan6_prefix
	fi

    ifconfig $wan_if down 2>>$test_log
    if [ $? -ne 0 ];then
	    echo "Error: ifconfig $wan_if down failed." >> $test_log
    fi
}


linkdown_dhcpv6_server_set()
{
    dhcp6c_kill
    dhcp6s_kill
}

del_default_wan6()
{
	default_wan6_name=`nv get default_wan6_name`
	if [ "-$1" == "-$default_wan6_name" ]; then
		nv set default_wan6_name=""
		nv set default_wan6_rel=""
	fi
}
get_wan_info $2 $3

case $1 in 
 "linkup") 
    linkup_get_wan_addr $2 $3

    ;;

 "linkdown") 
		if [ "-$2" == "-pswan" ]; then
			tc_tbf.sh down $def_cid
		fi
		linkdown_radvd_set
		linkdown_dhcpv6_server_set
		linkdown_route_set $2
		slaac_kill
		del_default_wan6 $wan_if
    ;;

esac


if [ "-$c_id" == "-0" -o "-$c_id" == "-$def_cid" ]; then
	(router_msg_proxy ipv6 wan_ipv6.sh >> $test_log 2>&1 || echo "Error: router_msg_proxy ipv6 wan_ipv6.sh failed." >> $test_log) &
fi
