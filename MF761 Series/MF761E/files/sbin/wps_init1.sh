#!/bin/sh
#
# script file to start network
#
# Usage: wps_init.sh {pbc | pin} {PINNUM}
#

##if [ $# -lt 2 ]; then echo "Usage: $0 {gw | ap} {all | bridge | wan}"; exit 1 ; fi
ROOT=`nv get wifi_root_dir`
LOG=$ROOT/wifi/realtek/slog

CONFIG_ROOT_DIR="$ROOT/wifi/realtek/rtl8192c"

ID=`nv get wifi_wps_index`
echo "enter wps init1.sh wifi_wps_index=$ID >>>>>>>>" >> $LOG

CONFIG_DIR=$CONFIG_ROOT_DIR/wlan0
WLAN_INTERFACE="wlan0"
 
echo "enter wps init.sh $CONFIG_DIR >>>>>>>>" >> $LOG
if [ -z "$SCRIPT_DIR" ]; then
	SCRIPT_DIR=`cat $CONFIG_ROOT_DIR/wifi_script_dir`
fi
START_WLAN_APP=$SCRIPT_DIR/wlanapp_8192c.sh
echo "0" > $CONFIG_DIR/wsc_upnp_enabled
echo "1" > $CONFIG_DIR/wsc_configured
echo "0" > $CONFIG_DIR/wsc_disabled
if [ $1 = "pbc" ]; then
	echo "2" > $CONFIG_DIR/wsc_method
else
	echo "1" > $CONFIG_DIR/wsc_method
	echo $2 > $CONFIG_DIR/wsc_pin
fi

echo "<<<<<wps init $1 $2 >>>>>>>>" >> $LOG


GET_WLAN_ENCRYPT=`cat $CONFIG_DIR/encrypt`
if [ "$GET_WLAN_ENCRYPT" = "2" ]; then #WPAPSK
	echo "2" > $CONFIG_DIR/wsc_auth
	GET_WLAN_AUTH=`cat $CONFIG_DIR/wpa_cipher`
	if [ "$GET_WLAN_AUTH" = "1" ]; then #TKIP
		echo "4" > $CONFIG_DIR/wsc_enc
	elif [ "$GET_WLAN_AUTH" = "2" ]; then #AES
		echo "8" > $CONFIG_DIR/wsc_enc
	else  #TKIPAES
		echo "12" > $CONFIG_DIR/wsc_enc
	fi
	GET_PSK=`cat $CONFIG_DIR/wpa_psk`
	echo $GET_PSK > $CONFIG_DIR/wsc_psk
elif [ "$GET_WLAN_ENCRYPT" = "4" ]; then #WPA2PSK
	echo "32" > $CONFIG_DIR/wsc_auth
	if [ "$GET_WLAN_AUTH" = "1" ]; then #TKIP
		echo "4" > $CONFIG_DIR/wsc_enc
	elif [ "$GET_WLAN_AUTH" = "2" ]; then #AES
		echo "8" > $CONFIG_DIR/wsc_enc
	else             #TKIPAES
		echo "12" > $CONFIG_DIR/wsc_enc
	fi
	GET_PSK=`cat $CONFIG_DIR/wpa_psk`
	echo $GET_PSK > $CONFIG_DIR/wsc_psk
elif [ "$GET_WLAN_ENCRYPT" = "6" ]; then #WPAPSKWPA2PSK
	echo "34" > $CONFIG_DIR/wsc_auth
	if [ "$GET_WLAN_AUTH" = "1" ]; then #TKIP
		echo "4" > $CONFIG_DIR/wsc_enc
	elif [ "$GET_WLAN_AUTH" = "2" ]; then #AES
		echo "8" > $CONFIG_DIR/wsc_enc
	else  #TKIPAES
		echo "12" > $CONFIG_DIR/wsc_enc
	fi
	GET_PSK=`cat $CONFIG_DIR/wpa_psk`
	echo $GET_PSK > $CONFIG_DIR/wsc_psk
else									 #open
	echo "1" > $CONFIG_DIR/wsc_auth
	echo "1" > $CONFIG_DIR/wsc_enc
fi

	
echo "0" > $CONFIG_DIR/wsc_manual_enabled
echo "0" > $CONFIG_DIR/wsc_upnp_enabled
echo "1" > $CONFIG_DIR/wsc_registrar_enabled
ESSID=`cat $CONFIG_DIR/ssid`
echo $ESSID > $CONFIG_DIR/wsc_ssid
echo "0" > $CONFIG_DIR/wsc_configbyextreg

echo -e "\n test to check if loop here\n" >> $LOG

BR_INTERFACE="br0"
echo -e "\n <<<${START_WLAN_APP##*/} start $WLAN_INTERFACE $BR_INTERFACE>>>" >> $LOG
$START_WLAN_APP start $WLAN_INTERFACE $BR_INTERFACE 
ERR=`echo $?`
if [ $ERR != 0 ]; then
	exit $ERR;
fi
