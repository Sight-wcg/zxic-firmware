#!/bin/sh

path_sh=`nv get path_sh`
. $path_sh/global.sh

echo "Info: tc_tbf $1 $2 start "
echo "Info: tc_tbf $1 $2 start" >> $test_log

UPLINK=`nv get tc_uplink`
DOWNLINK=`nv get tc_downlink`
def_cid=`nv get default_cid`
tc_enable=`nv get tc_enable`

if [ "$tc_enable" == "0" ]; then
	echo "tc_enable=0" 
	echo "tc_enable=0" >> $test_log
	exit 0
fi

need_jilian=`nv get need_jilian`
lanEnable=`nv get LanEnable`
if [ "$need_jilian" == "1" ]; then
    if [ "$lanEnable" == "1" ]; then
        IN=`nv get lan_name`
    elif [ "$lanEnable" == "0" ]; then
        IN=`nv get "ps_ext"$def_cid`
    fi
elif [ "$need_jilian" == "0" ]; then
    IN=`nv get lan_name`
fi

OUT4=$defwan_rel
OUT6=$defwan6_rel

if [ "$lanEnable" == "1" ]; then
    GATEWAY=`nv get lan_ipaddr`
fi

echo "IN=$IN, OUT4=$OUT4, OUT6=$OUT6, GATEWAY=$GATEWAY, DOWNLINK=$DOWNLINK, UPLINK=$UPLINK"
echo "IN=$IN, OUT4=$OUT4, OUT6=$OUT6, GATEWAY=$GATEWAY, DOWNLINK=$DOWNLINK, UPLINK=$UPLINK" >> $test_log

tc qdisc del dev $IN root
if [ "$OUT4" != "" ]; then
    tc qdisc del dev $OUT4 root
fi
if [ "$OUT6" != "" -a "$OUT6" != "$OUT4" ]; then
    echo "clear tc for $OUT6"
    tc qdisc del dev $OUT6 root
fi

fastnat_level=`nv get fastnat_level`
echo "Info: fastnat_level restore to：$fastnat_level" >> $test_log
echo $fastnat_level > /proc/net/fastnat_level

ifconfig $IN txqueuelen 10
if [ "$OUT4" != "" ]; then
    ifconfig $OUT4 txqueuelen 10
fi
if [ "$OUT6" != "" -a "$OUT6" != "$OUT4" ]; then
    ifconfig $OUT6 txqueuelen 10
fi

if [ "$1" == "down" -o "$1" == "DOWN" ]; then
	echo "traffic control down" 
	echo "traffic control down" >> $test_log
	exit 0
fi

if [ "$DOWNLINK" == "" -o "$DOWNLINK" == "0" ] && [ "$UPLINK" == "" -o "$UPLINK" == "0" ]; then
    echo "no need to traffic control"
    echo "no need to traffic control" >> $test_log
    exit 0
fi


echo 0 > /proc/net/fastnat_level

if [ "$DOWNLINK" != "0" -a "$DOWNLINK" != "" ]; then
    echo "traffic control for down"
    echo "traffic control for down" >> $test_log

    LOCAL=`nv get tc_local`
    SUM=`expr ${DOWNLINK} + ${LOCAL}`
    echo "LOCAL=$LOCAL, SUM=$SUM"
    echo "LOCAL=$LOCAL, SUM=$SUM" >> $test_log

    ifconfig $IN txqueuelen 1000

    tc qdisc add dev $IN root handle 1: htb default 20
    tc class add dev $IN parent 1: classid 1:1 htb rate ${SUM}bps
    tc class add dev $IN parent 1:1 classid 1:20 htb rate ${DOWNLINK}bps
    tc class add dev $IN parent 1:1 classid 1:10 htb rate ${LOCAL}bps
    tc qdisc add dev $IN parent 1:10 handle 10: sfq perturb 10
    tc qdisc add dev $IN parent 1:20 handle 20: sfq perturb 10
    tc filter add dev $IN protocol ip parent 1:0 prio 1 u32 match ip src ${GATEWAY}/32 match ip sport 80 0xffff flowid 1:10
fi

if [ "$UPLINK" != "0" -a "$UPLINK" != "" ]; then
    if [ "$OUT4" != "" ]; then
        echo "traffic control for up - ipv4"
        echo "traffic control for up - ipv4" >> $test_log
        ifconfig $OUT4 txqueuelen 1000
        tc qdisc add dev $OUT4 root handle 1: htb default 1
        tc class add dev $OUT4 parent 1: classid 1:1 htb rate ${UPLINK}bps
    fi

    if [ "$OUT6" != "" -a "$OUT6" != "$OUT4" ]; then
        echo "traffic control for up - ipv6"
        echo "traffic control for up - ipv6" >> $test_log
        ifconfig $OUT6 txqueuelen 1000
        tc qdisc add dev $OUT6 root handle 1: htb default 1
        tc class add dev $OUT6 parent 1: classid 1:1 htb rate ${UPLINK}bps
    fi
fi