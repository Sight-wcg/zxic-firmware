#! /bin/sh

path_sh=`nv get path_sh`
. $path_sh/global.sh

echo "Info: upnp_ipt_remove.sh start" >> $test_log

IPTABLES=iptables

EXTIF="$defwan_rel"

$IPTABLES -t nat -F MINIUPNPD
$IPTABLES -t nat -D PREROUTING -i $EXTIF -j MINIUPNPD
$IPTABLES -t nat -X MINIUPNPD

$IPTABLES -t filter -F MINIUPNPD
$IPTABLES -t filter -D FORWARD -i $EXTIF -o ! $EXTIF -j MINIUPNPD
$IPTABLES -t filter -X MINIUPNPD
