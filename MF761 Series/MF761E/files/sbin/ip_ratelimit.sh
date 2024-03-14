#!/bin/sh

path_sh=`nv get path_sh`
. $path_sh/global.sh

#流控上下行阀值，为空或为0表示不进行流控，暂时只实现上行的tc，下行将来根据实际需要再扩展实现
UPLINK=`nv get tc_uplink`
DOWNLINK=`nv get tc_downlink`
def_cid=`nv get default_cid`
tc_enable=`nv get tc_enable`
wifi_module=`nv get wifi_module`
m_ssid_enable=`nv get m_ssid_enable`

#上下行的出口dev需要根据实际情况选择
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


#定义网卡
if [ "$wifi_module" == "ssv6x5x" ]; then
    DOWNLOAD_DEV="wlan0"
else
    DOWNLOAD_DEV="wlan0-va0"
    DOWNLOAD_DEV1="wlan0-va1"
fi

UPLOAD_DEV=$defwan_rel
UPLOADv6_DEV=$defwan6_rel

#tc_enable=0，流量控制功能关闭
if [ "$tc_enable" == "0" ]; then
    DOWN="1000mbit"
    UP="1000mbit"
else
    DOWN=${DOWNLINK}bps
    UP=${UPLINK}bps
fi

if [ "$lanEnable" == "1" ]; then
    GATEWAY=`nv get lan_ipaddr`
fi


del_iptables_rule(){
    if [ -z "$1" ] || [ -z "$2" ] ;then
        echo "del_iptables_rule() run Error"
        exit
    fi

    ID=$1
    IP=$2

    iptables -t mangle -D POSTROUTING -d $IP -j MARK --set-mark 2$ID
    iptables -t mangle -D POSTROUTING -d $IP -j RETURN
    iptables -t mangle -D PREROUTING -s $IP -j MARK --set-mark 2$ID
    iptables -t mangle -D PREROUTING -s $IP -j RETURN

}

stop_tc(){

    tc qdisc del dev $DOWNLOAD_DEV root > /dev/null 2>&1
    if [ "$wifi_module" != "ssv6x5x" -a "$m_ssid_enable" == "1" ]; then
        tc qdisc del dev $DOWNLOAD_DEV1 root > /dev/null 2>&1
    fi

    tc qdisc del dev $UPLOAD_DEV root > /dev/null 2>&1
    if [ "$UPLOADv6_DEV" != "" -a "$UPLOADv6_DEV" != "$UPLOAD_DEV" ]; then
        tc qdisc del dev $UPLOADv6_DEV root > /dev/null 2>&1
    fi

    #给内核恢复快速转发级别
    fastnat_level=`nv get fastnat_level`
    echo $fastnat_level > /proc/net/fastnat_level

    ID=0
    while [ $ID -le "10" ]
    do
        RateLimitRulesTmp_ID=RateLimitRulesTmp_$ID
        RateLimitRulesTmp_x=`nv get ${RateLimitRulesTmp_ID}`
        if [ -z "$RateLimitRulesTmp_x" ]; then
            echo "${RateLimitRulesTmp_ID} is empty"
            break
        fi

        IP=`echo $RateLimitRulesTmp_x | cut -d \, -f 1`
        del_iptables_rule $ID $IP

        ID=`expr $ID + 1`
    done
}

add_rule(){
    if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ] || [ -z "$4" ];then
        echo "add_rule() run Error"
        exit
    fi

    ID=$1
    IP=$2
    DOWNSPEED=$3
    UPSPEED=$4

    tc class add dev $DOWNLOAD_DEV parent 10:1 classid 10:2$ID htb rate $DOWNSPEED ceil $DOWNSPEED prio 1
    tc qdisc add dev $DOWNLOAD_DEV parent 10:2$ID handle 100$ID: pfifo
    tc filter add dev $DOWNLOAD_DEV parent 10: protocol ip prio 100 handle 2$ID fw classid 10:2$ID
    if [ "$wifi_module" != "ssv6x5x" -a "$m_ssid_enable" == "1" ]; then
        tc class add dev $DOWNLOAD_DEV1 parent 10:1 classid 10:2$ID htb rate $DOWNSPEED ceil $DOWNSPEED prio 1
        tc qdisc add dev $DOWNLOAD_DEV1 parent 10:2$ID handle 100$ID: pfifo
        tc filter add dev $DOWNLOAD_DEV1 parent 10: protocol ip prio 100 handle 2$ID fw classid 10:2$ID
    fi
    iptables -t mangle -A POSTROUTING -d $IP -j MARK --set-mark 2$ID
    iptables -t mangle -A POSTROUTING -d $IP -j RETURN

    tc class add dev $UPLOAD_DEV parent 10:1 classid 10:2$ID htb rate $UPSPEED ceil $UPSPEED prio 1
    tc qdisc add dev $UPLOAD_DEV parent 10:2$ID handle 100$ID: pfifo
    tc filter add dev $UPLOAD_DEV parent 10: protocol ip prio 100 handle 2$ID fw classid 10:2$ID
    if [ "$UPLOADv6_DEV" != "" -a "$UPLOADv6_DEV" != "$UPLOAD_DEV" ]; then
        tc class add dev $UPLOADv6_DEV parent 10:1 classid 10:2$ID htb rate $UPSPEED ceil $UPSPEED prio 1
        tc qdisc add dev $UPLOADv6_DEV parent 10:2$ID handle 100$ID: pfifo
        tc filter add dev $UPLOADv6_DEV parent 10: protocol ip prio 100 handle 2$ID fw classid 10:2$ID
    fi
    iptables -t mangle -A PREROUTING -s $IP -j MARK --set-mark 2$ID
    iptables -t mangle -A PREROUTING -s $IP -j RETURN
}


start_tc(){
    stop_tc

    # 定义最顶层(根)队列规则，并指定 default 类别编号
    tc qdisc add dev $DOWNLOAD_DEV root handle 10: htb default 1
    if [ "$wifi_module" != "ssv6x5x" -a "$m_ssid_enable" == "1" ]; then
        tc qdisc add dev $DOWNLOAD_DEV1 root handle 10: htb default 1
    fi

    tc qdisc add dev $UPLOAD_DEV root handle 10: htb default 1
    if [ "$UPLOADv6_DEV" != "" -a "$UPLOADv6_DEV" != "$UPLOAD_DEV" ]; then
        tc qdisc add dev $UPLOADv6_DEV root handle 10: htb default 1
    fi

    # 定义第一层的 10:1 类别 (上行/下行 总带宽)
    tc class add dev $DOWNLOAD_DEV parent 10: classid 10:1 htb rate $DOWN ceil $DOWN
    if [ "$wifi_module" != "ssv6x5x" -a "$m_ssid_enable" == "1" ]; then
        tc class add dev $DOWNLOAD_DEV1 parent 10: classid 10:1 htb rate $DOWN ceil $DOWN
       
    fi
    
    tc class add dev $UPLOAD_DEV parent 10: classid 10:1 htb rate $UP ceil $UP
    if [ "$UPLOADv6_DEV" != "" -a "$UPLOADv6_DEV" != "$UPLOAD_DEV" ]; then
        tc class add dev $UPLOADv6_DEV parent 10: classid 10:1 htb rate $UP ceil $UP
    fi

    #暂定uc/v2都需要关闭快速转发
    echo 0 > /proc/net/fastnat_level 

    ID=0
    while [ $ID -le "10" ]
    do
        RateLimitRules_ID=RateLimitRules_$ID
        RateLimitRules_x=`nv get ${RateLimitRules_ID}`
    
        if [ -z "$RateLimitRules_x" ]; then
            echo "${RateLimitRules_ID} is empty"
            break
        fi

        RateLimitRulesTmp_ID=RateLimitRulesTmp_$ID
        nv set $RateLimitRulesTmp_ID=$RateLimitRules_x

        IP=`echo $RateLimitRules_x | cut -d \, -f 1`
        DOWNSPEED=`echo $RateLimitRules_x | cut -d \, -f 2`
        UPSPEED=`echo $RateLimitRules_x | cut -d \, -f 3`

        add_rule $ID $IP ${DOWNSPEED}kbit ${UPSPEED}kbit

        ID=`expr $ID + 1`
    done

    nv save
}

RateLimitEnable=`nv get RateLimitEnable`
#RateLimitEnable=0，限速控制功能关闭，直接退出
if [ "$RateLimitEnable" == "0" ] || [ "$RateLimitEnable" == "" ]; then
    echo "RateLimitEnable=0"
    stop_tc
    echo -e "$0 stop [ \033[1;32m"Success!"\033[0m ]"
    exit 0
fi

start_tc
echo -e "$0 start [ \033[1;32m"Success!"\033[0m ]"






