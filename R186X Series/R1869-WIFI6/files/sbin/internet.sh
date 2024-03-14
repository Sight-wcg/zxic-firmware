#!/bin/sh
path_sh=`nv get path_sh`
. $path_sh/global.sh
echo "Info: internet.sh start" > $test_log
echo "Info: `date +%m-%d %H:%M:%S`" >> $test_log

genSysFiles()
{
	login=`nv get Login`
	pass=`nv get Password`
	echo "$login::0:0:Adminstrator:/:/bin/sh" > /etc/passwd
	echo "$login:x:0:$login" > /etc/group
	echo "$login:$pass" > /tmp/tmpchpw
	chpasswd < /tmp/tmpchpw
	rm -f /tmp/tmpchpw
}
user_login=`cat /etc/passwd | grep admin`
[ -n "$user_login" ] || { genSysFiles;}

safe_run()
{
    ps_tmp=`nv get path_log`"ps.tmp"
    ps > ${ps_tmp}
	flag=`grep -w "$1" ${ps_tmp}`
	if [ "-${flag}" = "-" ];then
		$1 &
	fi
	rm -rf ${ps_tmp}
}

pswan=`nv get pswan`
ethwan=`nv get ethwan`
wifiwan=`nv get wifiwan`
echo 0 > /proc/sys/net/ipv6/conf/$pswan"1"/accept_ra
echo 0 > /proc/sys/net/ipv6/conf/$pswan"2"/accept_ra
echo 0 > /proc/sys/net/ipv6/conf/$pswan"3"/accept_ra
echo 0 > /proc/sys/net/ipv6/conf/$pswan"4"/accept_ra
echo 0 > /proc/sys/net/ipv6/conf/$pswan"5"/accept_ra
echo 0 > /proc/sys/net/ipv6/conf/$pswan"6"/accept_ra
echo 0 > /proc/sys/net/ipv6/conf/$pswan"7"/accept_ra
echo 0 > /proc/sys/net/ipv6/conf/$pswan"8"/accept_ra
if [ "-$ethwan" != "-" ]; then
    echo 0 > /proc/sys/net/ipv6/conf/$ethwan/accept_ra
fi
if [ "-$wifiwan" != "-" ]; then
    echo 0 > /proc/sys/net/ipv6/conf/$wifiwan/accept_ra
fi

echo 0 > /proc/sys/net/ipv4/conf/all/send_redirects
echo 0 > /proc/sys/net/ipv4/conf/default/send_redirects
echo 0 > /proc/sys/net/ipv4/conf/all/accept_redirects
echo 0 > /proc/sys/net/ipv4/conf/default/accept_redirects
echo 0 > /proc/sys/net/ipv6/conf/all/accept_redirects
echo 0 > /proc/sys/net/ipv6/conf/default/accept_redirects
echo 0 > /proc/sys/net/ipv4/conf/all/secure_redirects
echo 0 > /proc/sys/net/ipv4/conf/default/secure_redirects

echo 7200 > /proc/sys/net/netfilter/nf_conntrack_tcp_timeout_established


fast_usb=`nv get fast_usb`
lan_enable=`nv get LanEnable`

if [ "$lan_enable" != "2" ]; then
    echo $lan_if > /proc/net/br_name
fi

echo $fast_usb > /proc/net/usb_name

echo "" > /etc/resolv.conf

sh $path_sh/lan.sh

fastnat_level=`nv get fastnat_level`
echo "Info: set fastnat_level：$fastnat_level" >> $test_log
echo $fastnat_level > /proc/net/fastnat_level

nofast_port=`nv get nofast_port`
echo "Info: set nofast_port：$nofast_port" >> $test_log
echo $nofast_port > /proc/net/nofast_port

skb_debug=`nv get skb_debug`
echo "Info: set skb_debug：$skb_debug" >> $test_log
if [ "-$skb_debug" != "-1" ]; then
    echo 0 > /proc/net/skb_debug_off
fi

killall -9 miniupnpd
rm -rf $path_conf/inadyn.status

netdog -s exitsig=1


