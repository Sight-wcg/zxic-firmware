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
echo "enter trigger_wps1.sh wifi_wps_index=$ID >>>>>>>>" >> $LOG

CONFIG_DIR=$CONFIG_ROOT_DIR/wlan0
WLAN_INTERFACE="wlan0"


WPS_MODE=`cat $CONFIG_DIR/wsc_method`

echo "enter trigger_wps1.sh WPS_MODE=$WPS_MODE >>>>>>>>" >> $LOG

if [ "$WPS_MODE" = "2" ]; then
	echo "wscd -sig_pbc $WLAN_INTERFACE" >> $LOG
	wscd -sig_pbc $WLAN_INTERFACE
else
	PIN=`cat $CONFIG_DIR/wsc_pin`
	echo "iwpriv $WLAN_INTERFACE set_mib pin=$PIN" >> $LOG
	iwpriv $WLAN_INTERFACE set_mib pin=$PIN
fi

