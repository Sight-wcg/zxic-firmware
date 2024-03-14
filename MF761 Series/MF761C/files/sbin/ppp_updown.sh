#!/bin/sh
test_log=`nv get path_log`"te.log"

echo "Info: ppp_updown.sh $1 $2 start" >> $test_log

echo 1 > /proc/sys/net/ipv4/ip_forward

path_sh=`nv get path_sh`
path_conf=`nv get path_conf`
c_id=$2

ps_if=`nv get pswan`$c_id
eth_if=`nv get ppp_name`

#ip地址格式a.b.c.d
#获取ip并配置ps、eth,此处IP地址的配置规则为pdp激活ip地址最后一位的最后一个bit和倒数第二bit分别取反，该规则后续根绝需求可修改
ipaddr_set()
{
    pdp_ip=`nv get $ps_if"_ip"`
	#从a.b.c.d获取前三字节a.b.c
	ps_ip_abc=${pdp_ip%.*}
	#从a.b.c获取前两个字节a.b
	ps_ip_ab=${ps_ip_abc%.*}
	#从a.b.c获取第三字节c
	ps_ip_c=${ps_ip_abc##*.}
	#从a.b.c.d获取第四字节d
	ps_ip_d=${pdp_ip##*.}  
	
	#pdp_ip第四位的最后1bit取反
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

	#pdp_ip第四位的倒数第2bit取反	
	eth_ip=$ps_ip_ab"."$ps_ip_c2"."$ps_ip_d
	
	
	nv set $eth_if"_ip"=$eth_ip
	#ppp0网口在pppd中已经up，无需再次up
	ifconfig $eth_if $eth_ip
	if [ $? -ne 0 ];then
	    echo "Error: ifconfig $eth_if $eth_ip up failed." >> $test_log
    fi
	echo "Info: ifconfig $eth_if $eth_ip up" >> $test_log
}
#路由规则，ps与eth级联
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
	
	#本地网络配置
    iptables -t nat -I POSTROUTING -s $ps_ip -o $ps_if -j SNAT --to $pdp_ip
    
	route_info=`route|grep default`
	
	if [ "$route_info" == "" ];then
		route add default dev $ps_if
	else
		echo "Debug: default route already exist." >> $test_log
	fi
}

#删除对应的路由规则
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
	
    #reset nv
	nv set ppp_cid=""
    nv set $eth_if"_ip"=0.0.0.0
    nv set $eth_if"_nm"=0.0.0.0
    nv set $ps_if"_ip"=0.0.0.0
    nv set $ps_if"_pridns"=0.0.0.0
    nv set $ps_if"_secdns"=0.0.0.0
}

if [ "$1" == "linkup" ]; then  
        ipaddr_set
	    route_set		
elif [ "$1" == "linkdown" ]; then  
	    route_del
fi
