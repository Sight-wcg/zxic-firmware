#! /bin/sh

path_sh=`nv get path_sh`
. $path_sh/global.sh

echo "Info: upnp_ipt_init.sh start" >> $test_log
IPTABLES=iptables

EXTIF=$defwan_rel

$IPTABLES -t nat -N MINIUPNPD
$IPTABLES -t nat -I PREROUTING -i $EXTIF -j MINIUPNPD

$IPTABLES -t filter -N MINIUPNPD
$IPTABLES -t filter -I FORWARD -i $EXTIF -o ! $EXTIF -j MINIUPNPD
