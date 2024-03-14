#!/bin/sh
#
# script file to start network
#
# Usage: trigger_wps.sh 
#

##if [ $# -lt 2 ]; then echo "Usage: $0 {gw | ap} {all | bridge | wan}"; exit 1 ; fi

ROOT=`nv get wifi_root_dir`

LOG=$ROOT/wifi/realtek/slog
CONFIG_ROOT_DIR="$ROOT/wifi/realtek/rtl8192c"
CONFIG_DIR=$CONFIG_ROOT_DIR/wlan0

ID=`nv get wifi_wps_index`
echo "enter trigger_wps.sh wifi_wps_index=$ID >>>>>>>>" >> $LOG
ID=`expr $ID - 1`
echo "enter trigger_wps.sh ID=$ID >>>>>>>>" >> $LOG

if [ "$ID" = "0" ];then
#CONFIG_DIR=$CONFIG_ROOT_DIR/wlan0
#WLAN_INTERFACE="wlan0"
CONFIG_DIR=$CONFIG_ROOT_DIR/wlan0-va$ID
WLAN_INTERFACE="wlan0-va$ID"
else
CONFIG_DIR=$CONFIG_ROOT_DIR/wlan0-va$ID
WLAN_INTERFACE="wlan0-va$ID"
fi


WPS_MODE=`cat $CONFIG_DIR/wsc_method`
if [ "$WPS_MODE" = "2" ]; then
	echo "wscd -sig_pbc $WLAN_INTERFACE" >> $LOG
	wscd -sig_pbc $WLAN_INTERFACE
else
	PIN=`cat $CONFIG_DIR/wsc_pin`
	echo "iwpriv $WLAN_INTERFACE set_mib pin=$PIN" >> $LOG
	iwpriv $WLAN_INTERFACE set_mib pin=$PIN
fi

