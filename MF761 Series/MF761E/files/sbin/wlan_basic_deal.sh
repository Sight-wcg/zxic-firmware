#!/bin/sh
#
# script file to down up WLAN quickly
#


## error code
ERROR_SUCCESS=0
ERROR_INVALID_PARAMETERS=1
ERROR_NO_SUCH_DEVICE=2
ERROR_NO_CONFIG_FILE=3
ERROR_NO_SUCH_FILE=4
ERROR_NO_SUCH_DIRECTORY=5
ERROR_NULL_FILE=6
ERROR_NET_IF_UP_FAIL=7
ERROR_ADD_BR_FAIL=8
ERROR_ADD_IF_FAIL=9


ROOT=`nv get wifi_root_dir`
LOG=$ROOT/wifi/realtek/slog

IWPRIV=iwpriv
BR_UTIL=brctl

if [ $# -lt 1 ]; then
	echo "Usage: $0 wlan_interface" >> $LOG
	exit $ERROR_INVALID_PARAMETERS;
fi

SET_WLAN="iwpriv $1"
SET_WLAN_PARAM="$SET_WLAN set_mib"
IFCONFIG=ifconfig
SET_VA0="iwpriv wlan0-va0"
SET_VA1="iwpriv wlan0-va1"




br0_add_va1()
{
	HAS_BEEN_ADDED=`$BR_UTIL show | grep va1`
	if [ -z "$HAS_BEEN_ADDED" ]; then
		echo "$BR_UTIL addif br0 wlan0-va1"  >> $LOG
		$BR_UTIL addif br0 wlan0-va1 2> /dev/null
		
		if [ $? != 0 ]; then
			echo "Failed: $BR_UTIL addif br0 wlan0-va1"  >> $LOG
			exit $ERROR_ADD_IF_FAIL;
		fi

	fi
}

ifconfig_wlan0_up()
{
	ifconfig wlan0 up
	if [ $? != 0 ]; then
		exit $ERROR_NO_SUCH_DEVICE
	fi
}

ifconfig_wlan0_down()
{
	ifconfig wlan0 down
	if [ $? != 0 ]; then
		exit $ERROR_NO_SUCH_DEVICE
	fi
}

ifconfig_wlan0_va0_up()
{
	ifconfig wlan0-va0 up
	if [ $? != 0 ]; then
		exit $ERROR_NO_SUCH_DEVICE
	fi
}

ifconfig_wlan0_va0_down()
{
	ifconfig wlan0-va0 down
	if [ $? != 0 ]; then
		exit $ERROR_NO_SUCH_DEVICE
	fi
}

ifconfig_wlan0_va1_up()
{
	ifconfig wlan0-va1 up
	if [ $? != 0 ]; then
		exit $ERROR_NO_SUCH_DEVICE
	fi
}

ifconfig_wlan0_va1_down()
{
	ifconfig wlan0-va1 down
	if [ $? != 0 ]; then
		exit $ERROR_NO_SUCH_DEVICE
	fi
}
ifconfig_wlan0_vxd_down()
{
	ifconfig wlan0-vxd down
	if [ $? != 0 ]; then
		exit $ERROR_NO_SUCH_DEVICE
	fi
}

basic_open_va0()
{
	ifconfig_wlan0_up
	ifconfig_wlan0_va0_up
}				

basic_open_va0_va1()
{
	iwpriv wlan0-va0 set_mib  stanum=`nv get  MAX_Access_num`
    iwpriv wlan0-va1  set_mib  stanum=`nv get  m_MAX_Access_num`
	ifconfig_wlan0_up
	ifconfig_wlan0_va0_up
	ifconfig_wlan0_va1_up
	br0_add_va1
}

basic_open_va1()
{
	ifconfig_wlan0_va0_down
	iwpriv wlan0-va0 set_mib stanum=`nv get MAX_Access_num` 
	iwpriv wlan0-va1 set_mib stanum=`nv get m_MAX_Access_num` 
	ifconfig_wlan0_va0_up
	ifconfig_wlan0_va1_up
	br0_add_va1
}

basic_close_va1()
{
	iwpriv	wlan0-va1  clear_acl_table
	ifconfig_wlan0_va1_down
	
	ifconfig_wlan0_va0_down	
	iwpriv wlan0-va0 set_mib stanum=`nv get MAX_Access_num` 
	ifconfig_wlan0_va0_up
}

basic_closesta_openmssid()
{
	ifconfig_wlan0_va0_down 
	ifconfig_wlan0_vxd_down
	iwpriv wlan0-va0 set_mib  stanum=`nv get  MAX_Access_num` 
	iwpriv wlan0-va1 set_mib  stanum=`nv get  m_MAX_Access_num` 
	ifconfig_wlan0_va0_up 
	ifconfig_wlan0_va1_up
	br0_add_va1
}


main()
{
	if [ "$1" == "open_va0" ]; then
		basic_open_va0
	elif  [ "$1" == "open_va1" ]; then
		basic_open_va1
	elif [ "$1" == "close_va1" ]; then
		basic_close_va1
	elif [ "$1" == "open_va0_va1"  ]; then
		basic_open_va0_va1
	elif  [  "$1" == "close_sta_open_va1" ] ; then
		basic_closesta_openmssid
	else
		echo "$1 para wrong"  >> $LOG
		exit $ERROR_INVALID_PARAMETERS;
	fi

}

date +[%H:%M:%S]$1_start >> $LOG
main $1
date +[%H:%M:%S]$1_end >> $LOG
exit $ERROR_SUCCESS