#!/bin/sh
#
# $Id: upnp.sh,v 1.22.6.1 2008-10-02 12:57:42 winfred Exp $
#
# usage: upnp.sh
#
path_sh=`nv get path_sh`
. $path_sh/global.sh
echo "Info: upnp.sh start " >> $test_log


# stop all
killall -9 miniupnpd
sh $path_sh/upnp_ipt_remove.sh

# upnp
upnp=`nv get upnpEnabled`
if [ "$upnp" = "1" ]; then
	if [ -f $path_conf/pidfile/miniupnp.pid ]
	then
		rm -f $path_conf/pidfile/miniupnpd.pid
	fi
	
	if [ -f /var/run/miniupnpd.pid ]
	then
		rm -f /var/run/miniupnpd.pid
	fi	
	
	if [ -f $path_conf/miniupnpd.conf ]
	then
		echo "$path_conf/miniupnpd.conf already exist!"
	    rm $path_conf/miniupnpd.conf
	fi
	
	cp $path_ro/miniupnpd_temp.conf $path_conf/miniupnpd.conf
	
	gw=`nv get lan_ipaddr`
	. $path_sh/upnp_set_listenip.sh $gw/16
	
	route del -net 239.0.0.0 netmask 255.0.0.0 dev $lan_if
	route add -net 239.0.0.0 netmask 255.0.0.0 dev $lan_if 2>>$test_log
	if [ $? -ne 0 ];then
	    echo "Error: route add -net 239.0.0.0 netmask 255.0.0.0 dev $lan_if failed." >> $test_log
    fi
	. $path_sh/upnp_ipt_init.sh
	miniupnpd -f $path_conf/miniupnpd.conf &
fi
