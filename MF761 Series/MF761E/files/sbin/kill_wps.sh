#!/bin/sh
#
# script file to start network
#
# Usage: kill_wps.sh {pbc | pin} {PINNUM}
#

##if [ $# -lt 2 ]; then echo "Usage: $0 {gw | ap} {all | bridge | wan}"; exit 1 ; fi
ROOT=`nv get wifi_root_dir`

LOG=$ROOT/wifi/realtek/slog
CONFIG_ROOT_DIR="$ROOT/wifi/realtek/rtl8192c"
CONFIG_DIR=$CONFIG_ROOT_DIR/wlan0

ID=`nv get wifi_wps_index`
echo "enter kill_wps.sh wifi_wps_index=$ID >>>>>>>>" >> $LOG
ID=`expr $ID - 1`
echo "enter kill_wps.sh ID=$ID >>>>>>>>" >> $LOG

if [ "$ID" = "0" ];then
#CONFIG_DIR=$CONFIG_ROOT_DIR/wlan0
#WLAN_INTERFACE="wlan0"
CONFIG_DIR=$CONFIG_ROOT_DIR/wlan0-va$ID
WLAN_INTERFACE="wlan0-va$ID"
else
CONFIG_DIR=$CONFIG_ROOT_DIR/wlan0-va$ID
WLAN_INTERFACE="wlan0-va$ID"
fi


if [ -z "$SCRIPT_DIR" ]; then
	SCRIPT_DIR=`cat $CONFIG_ROOT_DIR/wifi_script_dir`
fi
START_WLAN_APP=$SCRIPT_DIR/wlanapp_8192c.sh

BR_INTERFACE="br0"
echo "<<<${START_WLAN_APP##*/} start $WLAN_INTERFACE $VIRTUAL_WLAN_INTERFACE $BR_INTERFACE>>>" >> $LOG
$START_WLAN_APP kill $WLAN_INTERFACE $VIRTUAL_WLAN_INTERFACE $BR_INTERFACE 
ERR=`echo $?`
if [ $ERR != 0 ]; then
	exit $ERR;
fi
