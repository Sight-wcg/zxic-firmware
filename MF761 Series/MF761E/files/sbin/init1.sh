#!/bin/sh
#
# script file to start network
#
# Usage: init.sh {gw | ap} {all | bridge | wan}
#

##if [ $# -lt 2 ]; then echo "Usage: $0 {gw | ap} {all | bridge | wan}"; exit 1 ; fi



## error code
ERROR_SUCCESS=0
ERROR_INVALID_PARAMETERS=1
ERROR_NO_SUCH_DEVICE=2
ERROR_NO_CONFIG_FILE=3
ERROR_NO_SUCH_FILE=4
ERROR_NO_SUCH_DIRECTORY=5
ERROR_NULL_FILE=6
ERROR_NET_IF_UP_FAIL=7
#CUR_PATH=`pwd`


ROOT=`nv get wifi_root_dir`
LOG=$ROOT/wifi/realtek/slog
CONFIG_ROOT_DIR="$ROOT/wifi/realtek/rtl8192c"

LOG1=$ROOT/wifi/realtek/slog1
LOG_LIMIT=128 #128K 
#if [ -e "$LOG"]; then
	LOG_SIZE=`du $LOG | cut -f1`
	if [ $LOG_SIZE -ge $LOG_LIMIT ]; then    
		mv $LOG $LOG1
	fi
#else
#	touch $LOG
#fi

SCRIPT_DIR=`cat $CONFIG_ROOT_DIR/wifi_script_dir`
BIN_DIR=`cat $CONFIG_ROOT_DIR/wifi_bin_dir`

if [ -z "$SCRIPT_DIR" ] || [ -z "$BIN_DIR" ]; then
	wifi_startup_fail_nvset
	exit $ERROR_NULL_FILE;
fi
if [ ! -d "$SCRIPT_DIR" ]; then
	echo "ERROR: $SCRIPT_DIR specify the path NOT exist." >> $LOG
	wifi_startup_fail_nvset
	exit $ERROR_NO_SUCH_DIRECTORY;
fi
if [ ! -d "$BIN_DIR" ]; then
	echo "ERROR: $BIN_DIR specify the path NOT exist." >> $LOG
	wifi_startup_fail_nvset
	exit $ERROR_NO_SUCH_DIRECTORY;
fi

#PATH=$PATH:$BIN_DIR
#export PATH

START_BRIDGE=$SCRIPT_DIR/bridge1.sh
#START_WLAN_APP=$SCRIPT_DIR/wlanapp_8192c.sh
START_WLAN=$SCRIPT_DIR/wlan_8192c1.sh

WLAN_PREFIX=wlan

# the following fields must manually set depends on system configuration. Not support auto config.
ROOT_WLAN=wlan0
ROOT_CONFIG_DIR=$CONFIG_ROOT_DIR/$ROOT_WLAN
WLAN_INTERFACE=$ROOT_WLAN
NUM_INTERFACE=0
#VIRTUAL_WLAN_INTERFACE="$ROOT_WLAN-va0 $ROOT_WLAN-va1 $ROOT_WLAN-va2 $ROOT_WLAN-va3"
VIRTUAL_WLAN_INTERFACE=""
NUM_VIRTUAL_INTERFACE=0
VXD_INTERFACE=""
ALL_WLAN_INTERFACE="$WLAN_INTERFACE $VIRTUAL_WLAN_INTERFACE $VXD_INTERFACE"

BR_UTIL=brctl
IFCONFIG=ifconfig
IWPRIV=iwpriv
FLASH_PROG=flash

export SCRIPT_DIR
export BIN_DIR
export WLAN_PREFIX
export ROOT_WLAN
export BR_UTIL


wifi_startup_fail_nvset() {
	date +[%H:%M:%S]init1.shenddddddddddddddddddd >> $LOG
	echo "wlan0 start failed "  >> $LOG
	echo " "  >> $LOG
}
rtl_get_available_wlan() {
	NUM=0
	VALID_WLAN_INTERFACE=""
	for WLAN in $WLAN_INTERFACE ; do
		NOT_EXIST=`$IFCONFIG $WLAN > /dev/null 2>&1; echo $?`
		if [ $NOT_EXIST = 0 ]; then
			CONFIG_DIR=$CONFIG_ROOT_DIR/$WLAN
			if [ ! -d "$CONFIG_DIR" ]; then
				echo "$CONFIG_DIR: No such directory"  >> $LOG
				wifi_startup_fail_nvset
				exit $ERROR_NO_CONFIG_FILE
			fi
			
			if [ -z "$VALID_WLAN_INTERFACE" ]; then
				VALID_WLAN_INTERFACE="$WLAN"
			else
				VALID_WLAN_INTERFACE="$VALID_WLAN_INTERFACE $WLAN"
			fi
			NUM=`expr $NUM + 1`
		fi
	done
	
	if [ "$NUM" = "0" ]; then
		echo "$WLAN_INTERFACE: No such device"  >> $LOG
		wifi_startup_fail_nvset
		exit $ERROR_NO_SUCH_DEVICE;
	fi
	WLAN_INTERFACE=$VALID_WLAN_INTERFACE
	NUM_INTERFACE=$NUM
	
	ALL_WLAN_INTERFACE="$WLAN_INTERFACE"
}

BR_INTERFACE=br0
BR_LAN1_INTERFACE=eth0

ENABLE_BR=1


# Generate WPS PIN number
rtl_generate_wps_pin() {
	for WLAN in $WLAN_INTERFACE ; do
		CONFIG_DIR=$CONFIG_ROOT_DIR/$WLAN
		GET_VALUE=`cat $CONFIG_DIR/wsc_pin`
		if [ "$GET_VALUE" = "00000000" ]; then
			##echo "27006672" > $CONFIG_DIR/wsc_pin
			$BIN_DIR/$FLASH_PROG gen-pin $WLAN
			$BIN_DIR/$FLASH_PROG gen-pin $WLAN-vxd
		fi
	done
}

rtl_set_mac_addr() {
	# Set Ethernet 0 MAC address
	GET_VALUE=`cat $ROOT_CONFIG_DIR/nic0_addr`
	ELAN_MAC_ADDR=$GET_VALUE
	$IFCONFIG $BR_LAN1_INTERFACE down
	$IFCONFIG $BR_LAN1_INTERFACE hw ether $ELAN_MAC_ADDR
}

# Usage: rtl_has_enable_vap wlan_interface
rtl_has_enable_vap() {
	for INTF in $VIRTUAL_WLAN_INTERFACE ; do
		case $INTF in
		$1-va[0-9])
			CONFIG_DIR=$CONFIG_ROOT_DIR/$INTF
			WLAN_DISABLED_VALUE=`cat $CONFIG_DIR/wlan_disabled`
			if [ "$WLAN_DISABLED_VALUE" = "0" ]; then
				return 1
			fi
			;;
		*)
			;;
		esac
	done
	
	return 0
}

# Start WLAN interface
rtl_start_wlan_if() {
	for WLAN in $ALL_WLAN_INTERFACE ; do
		echo "Initialize $WLAN interface" >> $LOG
		$IFCONFIG $WLAN down
		
		case $WLAN in
		$WLAN_PREFIX[0-9])		#ROOT_INTERFACE
			NO_VAP=`$IFCONFIG $WLAN-va0 > /dev/null 2>&1; echo $?`
			if [ $NO_VAP = 0 ]; then
				rtl_has_enable_vap $WLAN
				HAS_VAP=`echo $?`
				$IWPRIV $WLAN set_mib vap_enable=$HAS_VAP
				echo "$IWPRIV $WLAN set_mib vap_enable=$HAS_VAP" >> $LOG
			fi
			;;
		$WLAN_PREFIX[0-9]-vxd) ## station interface
#			echo "$IWPRIV $WLAN copy_mib" >> $LOG
#			$IWPRIV $WLAN copy_mib
#			WPA_SUPPLICAT=`ps | grep wpa_supplicant | grep -v grep`
#			echo "SUPPLICAT=$WPA_SUPPLICAT"  >> $LOG
			;;
		*)
			;;
		esac
		
		CONFIG_DIR=$CONFIG_ROOT_DIR/$WLAN
		WLAN_DISABLED_VALUE=`cat $CONFIG_DIR/wlan_disabled`

		if [ "$WLAN_DISABLED_VALUE" = 0 ]; then
			echo "<<<${START_WLAN##*/} $WLAN>>>" >> $LOG
			$START_WLAN $WLAN
			ERR=`echo $?`
			if [ $ERR != 0 ]; then
				echo "$START_WLAN $WLAN  failed"  >> $LOG
				wifi_startup_fail_nvset
				exit $ERR;
			fi
		else
			echo "$WLAN WLAN_DISABLED_VALUE=$WLAN_DISABLED_VALUE" >> $LOG
		fi
	done
}

# Enable WLAN interface
rtl_enable_wlan_if() {
	for WLAN in $ALL_WLAN_INTERFACE ; do
		CONFIG_DIR=$CONFIG_ROOT_DIR/$WLAN
		WLAN_DISABLED_VALUE=`cat $CONFIG_DIR/wlan_disabled`
		if [ "$WLAN_DISABLED_VALUE" = 0 ]; then
			echo "<<<ENABLE $WLAN>>>"
			IP_ADDR=`cat $CONFIG_DIR/ip_addr`
			$IFCONFIG $WLAN $IP_ADDR
			$IFCONFIG $WLAN up
			if [ $? != 0 ]; then
				wifi_startup_fail_nvset
				echo "ERROR ifconfig $WLAN up fail" >> $LOG
 				exit $ERROR_NET_IF_UP_FAIL;
			fi
		fi
	done
}

rtl_start_no_gw() {
	echo "<<<${START_BRIDGE##*/} $BR_INTERFACE $BR_LAN1_INTERFACE $WLAN_INTERFACE>>>"  >> $LOG
	$START_BRIDGE $BR_INTERFACE  $WLAN_INTERFACE
	ERR=`echo $?`
	if [ $ERR != 0 ]; then
		wifi_startup_fail_nvset
		exit $ERR;
	fi
	#CONFIG_DIR=$CONFIG_ROOT_DIR/$WLAN
	#GET_WPA_PSK=`cat $CONFIG_DIR/wpa_psk`
	#echo "222 GET_WPA_PSK is "$GET_WPA_PSK
	#echo "<<<${START_WLAN_APP##*/} start $WLAN_INTERFACE $VIRTUAL_WLAN_INTERFACE $BR_INTERFACE>>>"
	#$START_WLAN_APP start $WLAN_INTERFACE $VIRTUAL_WLAN_INTERFACE $BR_INTERFACE
	#ERR=`echo $?`
	#if [ $ERR != 0 ]; then
	#	exit $ERR;
	#fi
}


rtl_init() {
	date +[%H:%M:%S]init1.shstarttttttttttttttttt >> $LOG
	killall webs 2> /dev/null
	$BIN_DIR/webs -x
	
	echo "realtek rtl_get_available_wlan" >> $LOG
	rtl_get_available_wlan
##	rtl_set_mac_addr



	echo "realtek rtl_start_wlan_if" >> $LOG
	rtl_start_wlan_if
	
#NO_EXIST=1
	NO_EXIST=`$BR_UTIL > /dev/null 2>&1; echo $?`
	if [ "$NO_EXIST" = "127" ]; then
		echo "$BR_UTIL: NOT exist."  >> $LOG
		rtl_enable_wlan_if
	else
		#rtl_generate_wps_pin
		echo "realtek rtl_start_no_gw"  >> $LOG
		rtl_start_no_gw
	fi
	
    #iwpriv wlan0 stopps 1
    #iwpriv wlan0 set_mib ps_level=0	

	# add by TJ to modify sdio to 3.0
	iwpriv wlan0 efuse_set SD=3
	iwpriv wlan0 efuse_sync	
	  
	date +[%H:%M:%S]init1.shenddddddddddddddddddd >> $LOG
	echo " "  >> $LOG
	echo " "  >> $LOG
}

rtl_init
