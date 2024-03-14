#!/bin/sh


path_conf=`nv get path_conf`
test_log=`nv get telog_path`
if [ "$test_log" == "" ]; then
	test_log=`nv get path_log`"te.log"
fi
path_tmp=`nv get path_tmp`
path_ro=`nv get path_ro`

lan_if=`nv get lan_name`

pswan_name=`nv get pswan`
def_cid_tmp=`nv get default_cid`
pswan_if=$pswan_name$def_cid_tmp
ethwan_if=`nv get ethwan`
wifiwan_if=`nv get wifiwan`

defwan_if=`nv get default_wan_name`
defwan_rel=`nv get default_wan_rel`

defwan6_if=`nv get default_wan6_name`
defwan6_rel=`nv get default_wan6_rel`

udhcpc_kill()
{
	ps > ${path_tmp}/udhcpc.sh.$$
	udhcpc_pid=`awk 'BEGIN{temp1="'"${wan_if}"'";temp2="'$path_sh/udhcpc.sh'"}{if(index($0,temp1)>0 && index($0,temp2)>0){print $1}}' ${path_tmp}/udhcpc.sh.$$`
	rm -f ${path_tmp}/udhcpc.sh.$$
	[ -n "$udhcpc_pid" ] && { kill -9 $udhcpc_pid; echo "Info: kill udhcpc $udhcpc_pid " >> $test_log ; }
}
pppoe_kill()
{
	ps > ${path_tmp}/pppoecd.${wan_if}.$$
	pppoe_pid=`awk 'BEGIN{temp1="'"${wan_if}"'";temp2="pppoecd"}{if(index($0,temp1)>0 && index($0,temp2)>0){print $1}}' ${path_tmp}/pppoecd.${wan_if}.$$`
	rm -f ${path_tmp}/pppoecd.${wan_if}.$$
	[ -n "$pppoe_pid" ] && { kill -9 $pppoe_pid; echo "Info: kill pppoecd $pppoe_pid " >> $test_log ; }
}
dhcp6s_kill()
{
	ps > ${path_tmp}/${dhcp6s_conf##*/}.$$
	dhcp6s_pid=`awk 'BEGIN{temp1="'"${dhcp6s_conf}"'";temp2="dhcp6s"}{if(index($0,temp1)>0 && index($0,temp2)>0){print $1}}' ${path_tmp}/${dhcp6s_conf##*/}.$$`
	rm -f ${path_tmp}/${dhcp6s_conf##*/}.$$
    [ -n "$dhcp6s_pid" ] && { kill -9 $dhcp6s_pid; echo "Info: kill dhcp6s $dhcp6s_pid " >> $test_log ; }
}

radvd_kill()
{
	ps > ${path_tmp}/${radvd_conf##*/}.$$
	radvd_pid=`awk 'BEGIN{temp1="'"${radvd_conf}"'";temp2="radvd"}{if(index($0,temp1)>0 && index($0,temp2)>0){print $1}}' ${path_tmp}/${radvd_conf##*/}.$$`
	rm -f ${path_tmp}/${radvd_conf##*/}.$$
    [ -n "$radvd_pid" ] && { kill -9 $radvd_pid; echo "Info: kill radvd $radvd_pid " >> $test_log ; }
}

dhcp6c_kill()
{
	ps > ${path_tmp}/dhcp6c.${wan_if}.$$
	dhcp6c_pid=`awk 'BEGIN{temp1="'"${wan_if}"'";temp2="dhcp6c"}{if(index($0,temp1)>0 && index($0,temp2)>0){print $1}}' ${path_tmp}/dhcp6c.${wan_if}.$$`
	rm -f ${path_tmp}/dhcp6c.${wan_if}.$$
    [ -n "$dhcp6c_pid" ] && { kill -9 $dhcp6c_pid; echo "Info: kill dhcp6c $dhcp6c_pid " >> $test_log ; }
}

ndp_kill()
{
	ps > ${path_tmp}/${ndp_log##*/}.$$
	ndp_pid=`awk 'BEGIN{temp1="'"${ndp_log}"'";temp2="zte_ndp"}{if(index($0,temp1)>0 && index($0,temp2)>0){print $1}}' ${path_tmp}/${ndp_log##*/}.$$`
	rm -f ${path_tmp}/${ndp_log##*/}.$$
    [ -n "$ndp_pid" ] && { kill -9 $ndp_pid; echo "Info: kill ndp $ndp_pid " >> $test_log ; }
}

