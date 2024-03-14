#!/bin/sh

path_sh=`nv get path_sh`
. $path_sh/global.sh

if [ "-$3" == "-" ]; then
    c_id="0"
else
    c_id=$3
fi
def_cid=`nv get default_cid`

get_wan_if()
{
	case $1 in 
	"pswan")
		wan_if="$pswan_name"$2 ;;
	"ethwan")
		wan_if=$ethwan_if ;;
	"wifiwan")
		wan_if=$wifiwan_if ;;		
	esac

	mtu=`nv get mtu`
	ifconfig $wan_if mtu $mtu
}
state_set()
{
	if [ "-$wan_name" == "-wifiwan" ]; then
		nv set wifi_state="working"	
	elif [ "-$wan_name" == "-ethwan" ]; then
		nv set rj45_state="working"		
	fi
}
msg_zte_router()
{
	if [ "-$c_id" == "-0" -o "-$c_id" == "-$def_cid" ]; then
		(router_msg_proxy ipv4 wan_ipv4.sh >> $test_log 2>&1 || echo "Error: router_msg_proxy ipv4 wan_ipv4.sh failed." >> $test_log) &
	fi
}

linkup()
{
	wan_name=$1
	wan_mode=`nv get $wan_name"_mode"`

	get_wan_if $1 $2

	if [ "-$wan_mode" == "-static" ]; then
		wan_ip=`nv get "static_"$wan_name"_ip"`
		wan_gw=`nv get "static_"$wan_name"_gw"`
		wan_pridns=`nv get "static_"$wan_name"_pridns"`
		wan_secdns=`nv get "static_"$wan_name"_secdns"`
		wan_nm=`nv get "static_"$wan_name"_nm"`
		if [ "-$wan_name" != "-wifiwan" ]; then
			ifconfig $wan_if down 2>>$test_log
			if [ $? -ne 0 ];then
	            echo "Error: ifconfig $wan_if down failed." >> $test_log
            fi
			ifconfig $wan_if $wan_ip up 2>>$test_log
			if [ $? -ne 0 ];then
	            echo "Error: ifconfig $wan_if $wan_ip up failed." >> $test_log
            fi
		fi
		if [ "-$wan_name" == "-ethwan" ]; then
			nv set eth_curmode="static"
			(router_msg_proxy del_timer ethwan >> $test_log 2>&1 || echo "Error: router_msg_proxy del_timer failed." >> $test_log) &
		fi		

		state_set
		nv set $wan_if"_ip"=$wan_ip
		nv set $wan_if"_gw"=$wan_gw
		nv set $wan_if"_pridns"=$wan_pridns
		nv set $wan_if"_secdns"=$wan_secdns

		wan_pri=`nv get $1"_priority"`
		rt_num=`expr $wan_pri \* 10 + $c_id`
		ip rule add from $wan_ip table $rt_num 2>>$test_log
		if [ $? -ne 0 ];then
	        echo "Error: ip rule add from $wan_ip table $rt_num failed." >> $test_log
        fi
		ip route add default via $wan_gw table $rt_num 2>>$test_log
		if [ $? -ne 0 ];then
	        echo "Error: ip route add default via $wan_gw table $rt_num failed." >> $test_log
        fi
		ip route flush cache 2>>$test_log
		if [ $? -ne 0 ];then
	        echo "Error: ip route flush cache failed." >> $test_log
        fi

		msg_zte_router

	elif [ "-$wan_mode" == "-pdp" ]; then
		pswan_ip=`nv get $wan_if"_ip"`
		pswan_gw=`nv get $wan_if"_gw"`
		pswan_pridns=`nv get $wan_if"_pridns"`
		pswan_secdns=`nv get $wan_if"_secdns"`
		pswan_nm=`nv get $wan_if"_nm"`

		ifconfig $wan_if down 2>>$test_log
		if [ $? -ne 0 ];then
	        echo "Error: ifconfig $wan_if down failed." >> $test_log
        fi
		ifconfig $wan_if $pswan_ip up 2>>$test_log
		if [ $? -ne 0 ];then
	        echo "Error: ifconfig $wan_if $pswan_ip up failed." >> $test_log
        fi

		pswan_pri=`nv get pswan_priority`
		rt_num=`expr $pswan_pri \* 10 + $c_id`
		ip rule add from $pswan_ip table $rt_num 2>>$test_log
		if [ $? -ne 0 ];then
	        echo "Error: ip rule add from $pswan_ip table $rt_num failed." >> $test_log
        fi
		ip route add default via $pswan_gw table $rt_num 2>>$test_log
		if [ $? -ne 0 ];then
	        echo "Error: ip route add default via $pswan_gw table $rt_num failed." >> $test_log
        fi
		ip route flush cache 2>>$test_log
		if [ $? -ne 0 ];then
	        echo "Error: ip route flush cache failed." >> $test_log
        fi

		msg_zte_router

	elif [ "-$wan_mode" == "-auto" ]; then
		pppoe_user=`nv get pppoe_username`
		pppoe_pass=`nv get pppoe_cc`
		udhcpc_kill
		pppoe_kill

		if [ "-$wan_name" == "-ethwan" ]; then
			nv set eth_curmode=""
		fi	
		if [ "-$wan_name" != "-wifiwan" ]; then
			ifconfig $wan_if down 2>>$test_log
		    if [ $? -ne 0 ];then
	            echo "Error: ifconfig $wan_if down failed." >> $test_log
            fi
			ifconfig $wan_if up 2>>$test_log
			if [ $? -ne 0 ];then
	            echo "Error: ifconfig $wan_if up failed." >> $test_log
            fi
		fi

    	if [ "-${pppoe_user}" = "-" -a "-${pppoe_pass}" = "-" ];then
		    echo "auto wan_mode: pppoe_user is ${pppoe_user}, pppoe_pass is ${pppoe_pass}, so start dhcp client. " >> $test_log
			udhcpc -i $wan_if -s $path_sh/udhcpc.sh &
		else
			sh $path_sh/pppoe_dail.sh connect	
		fi

	elif [ "-$wan_mode" == "-dhcp" ]; then
		udhcpc_kill
		pppoe_kill

		if [ "-$wan_name" == "-pswan" ]; then
		    ifconfig $wan_if arp 2>>$test_log
			if [ $? -ne 0 ];then
	            echo "Error: ifconfig $wan_if arp failed." >> $test_log
            fi
		fi

		if [ "-$wan_name" == "-ethwan" ]; then
			nv set eth_curmode="dhcp"
		fi	

		if [ "-$wan_name" != "-wifiwan" ]; then
			ifconfig $wan_if down 2>>$test_log
			if [ $? -ne 0 ];then
	            echo "Error: ifconfig $wan_if down failed." >> $test_log
            fi
			ifconfig $wan_if up 2>>$test_log
			if [ $? -ne 0 ];then
	            echo "Error: ifconfig $wan_if up failed." >> $test_log
            fi
		fi
		udhcpc -i $wan_if -s $path_sh/udhcpc.sh &		

	elif [ "-$wan_mode" == "-pppoe" ]; then
		udhcpc_kill
		pppoe_kill

		if [ "-$wan_name" == "-ethwan" ]; then
			nv set eth_curmode="pppoe"
		fi	

		if [ "-$wan_name" != "-wifiwan" ]; then
			ifconfig $wan_if down 2>>$test_log
			if [ $? -ne 0 ];then
	            echo "Error: ifconfig $wan_if down failed." >> $test_log
            fi
			ifconfig $wan_if up 2>>$test_log
			if [ $? -ne 0 ];then
	            echo "Error: ifconfig $wan_if up failed." >> $test_log
            fi
		fi
		sh $path_sh/pppoe_dail.sh connect	
	fi

}

del_default_wan()
{
	default_wan_name=`nv get default_wan_name`
	if [ "$1" == "$default_wan_name" ]; then
		nv set default_wan_name=""
		nv set default_wan_rel=""
	fi
}

linkdown()
{
	wan_name=$1
	get_wan_if $1 $2

	udhcpc_kill
	pppoe_kill

	if [ "-$c_id" == "-0" -o "-$c_id" == "-$def_cid" ]; then
		echo 0 > /proc/sys/net/ipv4/ip_forward
	fi

	ifconfig $wan_if 0.0.0.0 2>>$test_log
	if [ $? -ne 0 ];then
	    echo "Error: ifconfig $wan_if 0.0.0.0 failed." >> $test_log
    fi
	if [ "$wan_name" == "wifiwan" ]; then
		echo $wan_if > /proc/net/dev_down
	else
		ifconfig $wan_if down 2>>$test_log
		if [ $? -ne 0 ];then
	        echo "Error: ifconfig $wan_if down failed." >> $test_log
        fi
	fi
	wan_ip=`nv get $wan_if"_ip"`
	wan_gw=`nv get $wan_if"_gw"`

	route del default gw $wan_gw dev $wan_if 

	wan_pri=`nv get $1"_priority"`
	rt_num=`expr $wan_pri \* 10 + $c_id`
	ip rule del from $wan_ip table $rt_num 
	ip route del default via $wan_gw table $rt_num 

	if [ "$wan_if" == "$defwan_if" ]; then
		nv set wan_ipaddr=""
	fi
	nv set $wan_if"_ip"=0.0.0.0
	nv set $wan_if"_nm"=0.0.0.0
	nv set $wan_if"_gw"=0.0.0.0
	nv set $wan_if"_pridns"=0.0.0.0
	nv set $wan_if"_secdns"=0.0.0.0
	pdp_type=`nv get "pdp_act_type"$def_cid`
	if [ "$2" == "$def_cid" -a "-$pdp_type" != "-IPv4v6" ]; then
		nv set default_cid=""
	fi
	del_default_wan $wan_if 
	msg_zte_router 

}

echo "Info: wan_ipv4.sh $1 $2 $3 start" >> $test_log
if [ "$1" == "linkup" ]; then
	linkup $2 $3

elif [ "$1" == "linkdown" ]; then
	if [ "-$2" == "-pswan" ]; then
		tc_tbf.sh down $def_cid
	fi
	linkdown $2 $3	
fi