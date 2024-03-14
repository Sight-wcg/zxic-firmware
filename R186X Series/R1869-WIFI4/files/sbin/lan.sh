#!/bin/sh
path_sh=`nv get path_sh`
. $path_sh/global.sh

br_set()
{
    br_name=$lan_if

    killall -9 udhcpd
    echo "ifconfig $br_name down...................."
    ifconfig $br_name down

    echo "brctl delbr $br_name......................"
    brctl delbr $br_name

    echo "brctl addbr $br_name......................"
    brctl addbr $br_name 2>>$test_log
    if [ $? -ne 0 ];then
        echo "Error: brctl addbr $br_name failed." >> $test_log
    fi
    echo "brctl setfd $br_name 0.1.................."
    brctl setfd $br_name 0.1 2>>$test_log
    if [ $? -ne 0 ];then
        echo "Error: brctl setfd $br_name 0.1 failed." >> $test_log
    fi
    echo "ifconfig lo up......................."
    ifconfig lo up 2>>$test_log
    if [ $? -ne 0 ];then
        echo "Error: ifconfig lo up failed." >> $test_log
    fi
    echo "ifconfig $br_name up......................"
    ifconfig $br_name up 2>>$test_log
    if [ $? -ne 0 ];then
        echo "Error: ifconfig $br_name up failed." >> $test_log
    fi

    echo 1 > /proc/sys/net/ipv4/conf/$br_name/arp_notify

    br_node=`nv get br_node`

    IFS_OLD=$IFS
    IFS="+"
    for device in $br_node
    do
        ifconfig $device up

        brctl addif $br_name $device 2>>$test_log
        if [ $? -ne 0 ];then
            echo "Error: brctl addif $br_name $device failed." >> $test_log
        fi
    done
    IFS=$IFS_OLD

}

lan_set()
{
    ip=`nv get lan_ipaddr`
    nm=`nv get lan_netmask`
    ifconfig $lan_if $ip netmask $nm 2>>$test_log
    if [ $? -ne 0 ];then
        echo "Error: ifconfig $lan_if $ip netmask $nm failed." >> $test_log
    fi

    webv6_enable=`nv get webv6_enable`
    ipv6=`nv get lan_ipv6addr`
    if [ "x$webv6_enable" == "x1" ]; then
        ifconfig $lan_if $ipv6
    if [ $? -ne 0 ];then
        echo "Error: ifconfig $lan_if $ipv6 failed." >> $test_log
    fi
    fi
}

lanip_proc()
{
	ip_value=`echo "$ip" | awk -F '.' '{printf $1 + 256* $2 + 256*256* $3 + 256*256*256* $4}'`
	nm_value=`echo "$nm" | awk -F '.' '{printf $1 + 256* $2 + 256*256* $3 + 256*256*256* $4}'`

    echo $ip_value > /sys/module/lanip_filter_ipv4/parameters/lan_ipaddr
    echo $nm_value > /sys/module/lanip_filter_ipv4/parameters/lan_netmask
}

main()
{
    lan_enable=`nv get LanEnable`
    if [ "x$lan_enable" == "x0" ]; then
        exit 0
    fi

    echo "Info: lan.sh start" >> $test_log

    if [ "x$lan_enable" == "x1" ]; then
        br_set
    fi

	if [ "x$lan_if" != "x" ]; then
        lan_set
    fi

    sw_name=`nv get swvlan`
    ifconfig $sw_name up
    natenable=`nv get natenable`
    dosenable=`nv get dosenable`
    if [[ "x$natenable" != "x0" || "x$dosenable" != "x0" ]]; then
        lanip_proc
    fi
    if [ "x$dosenable" != "x0" ]; then
        echo 1 > /sys/module/fast_common/parameters/lan_dos_enable
    fi




    echo "" > $path_conf/udhcpd.leases

    . $path_sh/user-config-udhcpd.sh

    dhcp=`nv get dhcpEnabled`
    if [ "$dhcp" == "1" ]; then
        echo "Info: config-udhcpd.sh lan -r 1 start" >> $test_log
        . $path_sh/config-udhcpd.sh "lan" -r 1
    fi

    dnsmasq -i $lan_if -r $path_conf/resolv.conf &
    . $path_sh/upnp.sh

    ipv6lanipaddrcmd="ifconfig $br_name | grep Scope:Link | sed 's/^.*addr: //g' | sed 's/\/.*$//g'"
    ipv6lanipaddr=`eval $ipv6lanipaddrcmd`
    nv set ipv6_lan_ipaddr=$ipv6lanipaddr
}

main
