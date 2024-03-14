#!/bin/sh
test_log=`nv get telog_path`
if [ "$test_log" == "" ]; then
	test_log=`nv get path_log`"te.log"
fi
echo "Info: psext_down.sh $1 start" >> $test_log
c_id=$1
ps_if=`nv get pswan`$c_id
eth_if=`nv get "ps_ext"$c_id`
ext_br="br"$c_id

route_del()
{
    pdp_ip=`nv get $ps_if"_pdp_ip"`
	ps_ip=`nv get $ps_if"_ip"`
	br_ip=`nv get $ext_br"_ip"`
	marknum=`expr $c_id + 10`
	rt_num=`expr $c_id + 100`

	iptables -t mangle -D PREROUTING -i $ext_br -j MARK --set-mark $marknum
	ip rule del from $pdp_ip fwmark $marknum table $rt_num 
    ip route del default dev $ps_if table $rt_num

    marknum=`expr $c_id + 20`
	rt_num=`expr $c_id + 120`
    iptables -t mangle -D PREROUTING -i $ps_if -j MARK --set-mark $marknum
	ip rule del to $pdp_ip fwmark $marknum table $rt_num
    ip route del default dev $ext_br table $rt_num 
    iptables -t nat -D POSTROUTING -s $ps_ip -o $ps_if -j SNAT --to $pdp_ip
    if [ $? -ne 0 ];then
        echo "cmd <<iptables -t nat -D POSTROUTING -s $ps_ip -o $ps_if -j SNAT --to $pdp_ip>> exec failed"  >> $test_log
    fi
    route delete default dev $ps_if
    if [ $? -ne 0 ];then
        echo "cmd <<route delete default dev $ps_if>> exec failed"  >> $test_log
    fi

    ifconfig $ext_br 0.0.0.0
	ifconfig $ext_br down 2>>$test_log
	if [ $? -ne 0 ];then
	    echo "Error: ifconfig $ext_br down failed." >> $test_log
    fi

    ifconfig $ps_if 0.0.0.0
	ifconfig $ps_if down 2>>$test_log
	if [ $? -ne 0 ];then
	    echo "Error: ifconfig $ps_if down failed." >> $test_log
    fi

    nv set $ext_br"_ip"=0.0.0.0
    nv set $ext_br"_nm"=0.0.0.0
    nv set $ps_if"_pdp_ip"=0.0.0.0
    nv set $ps_if"_pridns"=0.0.0.0
    nv set $ps_if"_secdns"=0.0.0.0
    nv set $ps_if"_ip"=0.0.0.0
}
tc_tbf.sh down $c_id
route_del
ifconfig $eth_if down
ifconfig $ext_br down
brctl delif $ext_br $eth_if
brctl delbr $ext_br 
