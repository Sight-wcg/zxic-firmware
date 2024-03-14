#!/bin/sh
#
# script file to start wlan applications (IAPP, Auth, Autoconf) daemon
#
# Usage: wlanapp.sh [start|kill] wlan_interface...br_interface
#

## error code
ERROR_WSCD_START_FAIL=8

if [ $# -lt 2 ] || [ $1 != 'start' -a $1 != 'kill' ] ; then 
	echo "Usage: $0 [start|kill] wlan_interface...br_interface" >> $LOG
	exit 1 
fi
#CUR_PATH=`pwd`
#TOP_VAR_DIR="/etc_ro"
ROOT=`nv get wifi_root_dir`
LOG=$ROOT/wifi/realtek/slog

TOP_VAR_DIR="$ROOT/wifi/realtek"
TOP_ETC_DIR="/etc_ro/realtek/ath"
TOP_TMP_DIR="$ROOT/tmp"
CONFIG_ROOT_DIR="$ROOT/wifi/realtek/rtl8192c"

if [ ! -d "$TOP_TMP_DIR" ]; then
    mkdir $TOP_TMP_DIR
fi

if [ -z "$BIN_DIR" ]; then
	BIN_DIR=`cat $CONFIG_ROOT_DIR/wifi_bin_dir`
fi

if [ -z "$WLAN_PREFIX" ]; then
	WLAN_PREFIX=wlan
fi
#WLAN_PREFIX_LEN=${#WLAN_PREFIX}
#WLAN_NAME_LEN=$((WLAN_PREFIX_LEN + 1))

if [ -z "$ROOT_WLAN" ]; then
#	ROOT_WLAN=${2:0:$WLAN_NAME_LEN}
	ROOT_WLAN=${2%%-*}
fi
ROOT_CONFIG_DIR=$CONFIG_ROOT_DIR/$ROOT_WLAN

GET_VALUE=
GET_VALUE_TMP=
KILLALL=killall
FLASH_PROG=flash
SLEEP=sleep

START=1
PARAM_NUM=$#
PARAM_ALL=$*
PARAM1=$1
PARAM_BR=
WLAN_INTERFACE=

WLAN0_MODE=
WLAN0_DISABLED=
WLAN0_WSC_DISABLED=

WLAN1_MODE=0
WLAN1_DISABLED=1
WLAN1_WSC_DISABLED=1
both_band_ap=0

rtl_check_wlan_band(){

	WLAN0_MODE=`cat $CONFIG_ROOT_DIR/wlan0/wlan_mode`
	WLAN0_DISABLED=`cat $CONFIG_ROOT_DIR/wlan0/wlan_disabled`
	WLAN0_WSC_DISABLED=`cat $CONFIG_ROOT_DIR/wlan0/wsc_disabled`

	if [ -d "$CONFIG_ROOT_DIR/wlan1" ] ; then
		WLAN1_MODE=`cat $CONFIG_ROOT_DIR/wlan1/wlan_mode`
		WLAN1_DISABLED=`cat $CONFIG_ROOT_DIR/wlan1/wlan_disabled`
		WLAN1_WSC_DISABLED=`cat $CONFIG_ROOT_DIR/wlan1/wsc_disabled`
	fi

	if [ "$WLAN0_MODE" = "0" -o "$WLAN0_MODE" = "3" ] && [ "$WLAN1_MODE" = "0" -o "$WLAN1_MODE" = "3" ] && [ "$WLAN0_DISABLED" = "0" ] && [ "$WLAN1_DISABLED" = "0" ] && [ "$WLAN0_WSC_DISABLED" = "0" ] && [ "$WLAN1_WSC_DISABLED" = "0" ]; then
		both_band_ap = 1
	fi
}

rtl_check_wlan_if() {

	echo "wlanapp_8192c.sh --rtl_check_wlan_if" >> $LOG

	if [ $PARAM_NUM -ge 1 ]; then
		for ARG in $PARAM_ALL ; do
			case $ARG in
			$WLAN_PREFIX*)
				if [ -z "$WLAN_INTERFACE" ]; then
					WLAN_INTERFACE="$ARG"
				else
					WLAN_INTERFACE="$WLAN_INTERFACE $ARG"
				fi
				;;
			*)
				PARAM_BR=$ARG
				;;
			esac
		done
	fi
}
	
DEBUG_EASYCONF=
VXD_INTERFACE=


## kill 802.1x, autoconf and IAPP daemon ##
rtl_kill_iwcontrol_pid() { 
	PIDFILE="$TOP_VAR_DIR/run/iwcontrol.pid"
	echo "wlanapp_8192c.sh --rtl_kill_iwcontrol_pid"  >> $LOG
	if [ -f $PIDFILE ] ; then
		PID=`cat $PIDFILE`
		echo "IWCONTROL_PID=$PID"  >> $LOG
		if [ "$PID" != "0" ]; then
			kill -9 $PID 2>/dev/null
		fi
		rm -f $PIDFILE
	fi
}


rtl_kill_wlan_pid() {

	echo "wlanapp_8192c.sh --rtl_kill_wlan_pid"  >>  $LOG
	for WLAN in $WLAN_INTERFACE ; do
		PIDFILE=$TOP_VAR_DIR/run/auth-$WLAN.pid
		if [ -f $PIDFILE ] ; then
			PID=`cat $PIDFILE`
			echo "AUTH_PID=$PID"
			if [ "$PID" != "0" ]; then
				kill -9 $PID 2>/dev/null
			fi
			rm -f $PIDFILE
			
			PIDFILE=$TOP_VAR_DIR/run/auth-$WLAN-vxd.pid 
			if [ -f $PIDFILE ] ; then		
				PID=`cat $PIDFILE`
				if [ "$PID" != "0" ]; then
					kill -9 $PID 2>/dev/null
				fi
				rm -f $PIDFILE       		
			fi
		fi
		
		# for WPS ---------------------------------->>
		PIDFILE=$TOP_VAR_DIR/run/wscd-$WLAN.pid
		if [ "$both_band_ap" = "1" ]; then
			PIDFILE=$TOP_VAR_DIR/run/wscd-wlan0-wlan1.pid
		fi
		
		if [ -f $PIDFILE ] ; then
			PID=`cat $PIDFILE`
			echo "WSCD_PID=$PID"  >> $LOG
			if [ "$PID" != "0" ]; then
				kill -9 $PID 2>/dev/null
			fi
			rm -f $PIDFILE   
		fi 
	done
	#<<----------------------------------- for WPS
}

## start 802.1x daemon ##
DEAMON_CREATED=0
VALID_WLAN_INTERFACE=


rtl_start_wlan() {
	echo "rtl_start_wlan WLAN_INTERFACE is "$WLAN_INTERFACE >> $LOG
	for WLAN in $WLAN_INTERFACE ; do
		CONFIG_DIR=$CONFIG_ROOT_DIR/$WLAN
		echo "rtl_start_wlan start-1------------ CONFIG_DIR is "$CONFIG_DIR  >> $LOG
		GET_VALUE_WLAN_DISABLED=`cat $CONFIG_DIR/wlan_disabled`
		if [ "$GET_VALUE_WLAN_DISABLED" != 0 ]; then
			continue
		fi
		
		GET_VALUE_WLAN_MODE=`cat $CONFIG_DIR/wlan_mode`
		GET_WLAN_WPA_AUTH_TYPE=`cat $CONFIG_DIR/wpa_auth`
		GET_WLAN_ENCRYPT=`cat $CONFIG_DIR/encrypt`
		
		EXT=${WLAN#$WLAN_PREFIX[0-9]}
		EXT=${EXT#-}
		VAP_AUTH_ENABLE=0
		ROOT_AUTH_ENABLE=0
		
		_ENABLE_1X=0
		_USE_RS=0

		if [ "$GET_WLAN_ENCRYPT" -lt 2 ]; then
			GET_ENABLE_1X=`cat $CONFIG_DIR/enable_1x`
			GET_MAC_AUTH_ENABLED=`cat $ROOT_CONFIG_DIR/mac_auth_enabled`
			if [ "$GET_ENABLE_1X" != 0 ] || [ "$GET_MAC_AUTH_ENABLED" != 0 ]; then
				_ENABLE_1X=1
				_USE_RS=1
			fi
		else
			_ENABLE_1X=1
			if  [ "$GET_WLAN_WPA_AUTH_TYPE" = 1 ]; then
				_USE_RS=1
			fi		
		fi

		echo "_ENABLE_1X= $_ENABLE_1X" >> $LOG	
		ROLE=
		if [ "$_ENABLE_1X" != 0 ]; then	
			echo "$BIN_DIR/$FLASH_PROG wpa $WLAN $TOP_VAR_DIR/wpa-$WLAN.conf $WLAN" >> $LOG
			$BIN_DIR/$FLASH_PROG wpa $WLAN $TOP_VAR_DIR/wpa-$WLAN.conf $WLAN
			if [ "$GET_VALUE_WLAN_MODE" = '1' ]; then
				GET_VALUE=`cat $CONFIG_DIR/network_type`
				if [ "$GET_VALUE" = '0' ]; then
					ROLE=client-infra
				else
					ROLE=client-adhoc			
				fi
			else
				ROLE=auth
			fi

			VAP_NOT_IN_PURE_AP_MODE=0		
		
			
			if [ "$GET_VALUE_WLAN_MODE" = '0' ] && [ "$VAP_NOT_IN_PURE_AP_MODE" = '0' ]; then
				if  [ "$GET_WLAN_WPA_AUTH_TYPE" != 2 ] || [ "$_USE_RS" != 0 ]; then
					echo "$BIN_DIR/auth $WLAN $PARAM_BR $ROLE $TOP_VAR_DIR/wpa-$WLAN.conf" >> $LOG
					$BIN_DIR/auth $WLAN $PARAM_BR $ROLE $TOP_VAR_DIR/wpa-$WLAN.conf
					
					DEAMON_CREATED=1
					ROOT_AUTH_ENABLE=1
				fi
		
			fi
		fi
		
		if [ "$EXT" = "vxd" ]; then	
			if [ "$ROLE" != "auth" ] || [ "$ROLE" = "auth" -a "$_USE_RS" != 0 ]; then
				VXD_INTERFACE=$WLAN
			fi
		else
			GET_WSC_DISABLE=`cat $CONFIG_DIR/wsc_disabled`
			#|| [ $GET_WSC_DISABLE = 0 ]
			if [ $ROOT_AUTH_ENABLE = 1 ] || [ $GET_WSC_DISABLE = 0 ]; then
				if [ -z "$VALID_WLAN_INTERFACE" ]; then
					VALID_WLAN_INTERFACE="$WLAN"
				else
					VALID_WLAN_INTERFACE="$VALID_WLAN_INTERFACE $WLAN"
				fi
			fi
		fi
		
	done

}

#end of start wlan


# for WPS ------------------------------------------------->>
rtl_start_wps() {


	if [ ! -e $BIN_DIR/wscd ]; then
		echo "wscd not exist $BIN_DIR is " $BIN_DIR  >> $LOG
		return;
	fi
	echo "rtl_start_wps  WLAN is " $WLAN >> $LOG
	echo "VALID_WLAN_INTERFACE is " $VALID_WLAN_INTERFACE  >> $LOG
	
	
	for WLAN in $VALID_WLAN_INTERFACE ; do
		EXT=${WLAN#$WLAN_PREFIX[0-9]}
		EXT=${EXT#-}
		echo  "EXT=$EXT" >> $LOG
		if [ "$EXT" = "" ] || [ "$EXT" = "va0" ] || [ "$EXT" = "va1" ] || [ "$EXT" = "vxd" ]; then
			
			USE_IWCONTROL=1
			DEBUG_ON=0
			_ENABLE_1X=0
			WSC=1
			CONFIG_DIR=$CONFIG_ROOT_DIR/$WLAN
			CONF_FILE=$TOP_VAR_DIR/wsc-$WLAN.conf
			FiFO_File=$TOP_VAR_DIR/wscd-$WLAN.fifo
			
			echo "rtl_start_wps  CONFIG_DIR is " $CONFIG_DIR  >> $LOG
			
			GET_WSC_DISABLE=`cat $CONFIG_DIR/wsc_disabled`
			GET_VALUE_WLAN_DISABLED=`cat $CONFIG_DIR/wlan_disabled`
			GET_VALUE_WLAN_MODE=`cat $CONFIG_DIR/wlan_mode`
			GET_WLAN_ENCRYPT=`cat $CONFIG_DIR/encrypt`
			GET_WLAN_WPA_AUTH_TYPE=`cat $CONFIG_DIR/wpa_auth`

			if [ "$GET_WLAN_ENCRYPT" -lt 2 ]; then
				GET_ENABLE_1X=`cat $CONFIG_DIR/enable_1x`
				GET_MAC_AUTH_ENABLED=`cat $CONFIG_DIR/mac_auth_enabled`
				if [ "$GET_ENABLE_1X" != 0 ] || [ "$GET_MAC_AUTH_ENABLED" != 0 ]; then
					_ENABLE_1X=1
				fi
			else
				_ENABLE_1X=1
			fi
			echo "_ENABLE_1X is " $_ENABLE_1X  >> $LOG
			if [ "$EXT" = "vxd" ]; then
				GET_VALUE_WLAN_CURR_MODE=`cat $CONFIG_DIR/wlan_mode`
				if [ $GET_VALUE_WLAN_CURR_MODE = 1 ]; then
					GET_WSC_DISABLE = 1
				fi
			fi
			
			if [ $GET_WSC_DISABLE != 0 ]; then
				echo "GET_WSC_DISABLE is " $GET_WSC_DISABLE   >> $LOG
				WSC=0
			else
				if  [ "$GET_VALUE_WLAN_DISABLED" != 0 ] || [ "$GET_VALUE_WLAN_MODE" = 2 ]; then
					echo "GET_VALUE_WLAN_DISABLED is "$GET_VALUE_WLAN_DISABLED  >> $LOG
					echo "GET_VALUE_WLAN_MODE is "$GET_VALUE_WLAN_MODE  >> $LOG
					WSC=0
				else  
					if [ $GET_VALUE_WLAN_MODE = 1 ]; then	
						GET_VALUE=`cat $CONFIG_DIR/network_type`
						if [ "$GET_VALUE" != 0 ]; then
							echo "network_type is "$GET_VALUE  >> $LOG
							WSC=0
						fi
					fi
					if [ $GET_VALUE_WLAN_MODE = 0 ]; then	
						if [ $GET_WLAN_ENCRYPT -lt 2 ] && [ $_ENABLE_1X != 0 ]; then
							echo "GET_WLAN_ENCRYPT is "$GET_WLAN_ENCRYPT  >> $LOG
							echo "_ENABLE_1X is "$_ENABLE_1X  >> $LOG
							WSC=0
						fi			
						if [ $GET_WLAN_ENCRYPT -ge 2 ] && [ $GET_WLAN_WPA_AUTH_TYPE = 1 ]; then
							echo "GET_WLAN_ENCRYPT is "$GET_WLAN_ENCRYPT  >> $LOG
							echo "GET_WLAN_WPA_AUTH_TYPE is "$GET_WLAN_WPA_AUTH_TYPE  >> $LOG
							WSC=0
						fi			
					fi
				fi
			fi
			echo "-----------------WSC is "$WSC  >> $LOG 
			if [ $WSC = 1 ]; then
				if [ ! -f $TOP_VAR_DIR/wps/simplecfgservice.xml ]; then
					if [ -e $TOP_VAR_DIR/wps ]; then
						rm $TOP_VAR_DIR/wps -rf
					fi
					mkdir $TOP_VAR_DIR/wps
					#cp $TOP_ETC_DIR/simplecfg*.xml $TOP_VAR_DIR/wps
					cat $TOP_ETC_DIR/simplecfgservice.xml > $TOP_VAR_DIR/wps/simplecfgservice.xml
				fi

				if [ $GET_VALUE_WLAN_MODE = 1 ]; then			
					UPNP=0
					_CMD="-mode 2"
				else		
					GET_WSC_UPNP_ENABLED=`cat $CONFIG_DIR/wsc_upnp_enabled`
					UPNP=$GET_WSC_UPNP_ENABLED
					_CMD="-start"
				fi
				WPS_MODE=`cat $CONFIG_DIR/wsc_method`
				if [ "$WPS_MODE" = "1" ]; then
					_CMD="$_CMD -method 1"
				fi
				echo " UPNP is " $UPNP >> $LOG
				if [ $UPNP = 1 ]; then
					route del -net 239.255.255.250 netmask 255.255.255.255 dev "$PARAM_BR"
					route add -net 239.255.255.250 netmask 255.255.255.255 dev "$PARAM_BR"
				fi
		
				if [ "$both_band_ap" = "1" ]; then
					_CMD="$_CMD -both_band_ap"	
				fi
				echo "$BIN_DIR/$FLASH_PROG upd-wsc-conf $TOP_ETC_DIR/wscd.conf $CONF_FILE $WLAN"  >> $LOG
				$BIN_DIR/$FLASH_PROG upd-wsc-conf $TOP_ETC_DIR/wscd.conf $CONF_FILE $WLAN
				
				_CMD="$_CMD -c $CONF_FILE -w $WLAN"
		
				if [ $DEBUG_ON = 1 ]; then
					_CMD="$_CMD -debug"	
				fi	
				if [ $USE_IWCONTROL = 1 ]; then
					_CMD="$_CMD -fi $FiFO_File"
					DEAMON_CREATED=1
					echo "DEAMON_CREATED=1" >> $LOG
				fi
		
				if [ -f "$TOP_VAR_DIR/wps_start_pbc" ]; then		
					_CMD="$_CMD -start_pbc"
					rm -f $TOP_VAR_DIR/wps_start_pbc
				fi

				if [ -f "$TOP_VAR_DIR/wps_start_pin" ]; then		
					_CMD="$_CMD -start"
					rm -f $TOP_VAR_DIR/wps_start_pin
				fi	
				if [ -f "$TOP_VAR_DIR/wps_local_pin" ]; then		
					PIN=`cat $TOP_VAR_DIR/wps_local_pin`		
					_CMD="$_CMD -local_pin $PIN"
					rm -f $TOP_VAR_DIR/wps_local_pin
				fi
				if [ -f "$TOP_VAR_DIR/wps_peer_pin" ]; then		
					PIN=`cat $TOP_VAR_DIR/wps_peer_pin`		
					_CMD="$_CMD -peer_pin $PIN"
					rm -f $TOP_VAR_DIR/wps_peer_pin
				fi				
				WSC_CMD=$_CMD
				echo "$BIN_DIR/wscd $WSC_CMD -daemon" >> $LOG
				$BIN_DIR/wscd $WSC_CMD -daemon
				echo "<<<<<<<<<<wscd >>>>>>>>>>> over" >> $LOG
				WAIT=5
				while [ $USE_IWCONTROL != 0 -a $WAIT != 0 ]		
				do	
					if [ -e $FiFO_File ]; then
						break;
					else
						$SLEEP 1
						WAIT=`expr $WAIT - 1`
						#WAIT=$((WAIT - 1))
					fi
				done
				if [ $WAIT = 0 ]; then
					exit $ERROR_WSCD_START_FAIL;
				fi
			fi
		fi
	done
}
#<<--------------------------------------------------- for WPS

rtl_start_iwcontrol() {
	echo "rtl_start_iwcontrol"  >> $LOG
	if [ $DEAMON_CREATED = 1 ]; then
		echo "$BIN_DIR/iwcontrol $VALID_WLAN_INTERFACE $VXD_INTERFACE $POLL"  >> $LOG
		$BIN_DIR/iwcontrol $VALID_WLAN_INTERFACE $VXD_INTERFACE $POLL
	fi
}

rtl_wlanapp() {

	echo "rtl_wlanapp"  >> $LOG

	if [ $PARAM1 = 'kill' ]; then
		START=0
	fi
	rtl_check_wlan_if
	if [ -z "$WLAN_INTERFACE" ]; then
		echo "Error in $0, no wlan interface is given!"  >> $LOG
		exit 0
	fi
	rtl_kill_iwcontrol_pid
	rtl_kill_wlan_pid
	rm -f $TOP_VAR_DIR/*.fifo
	if [ $START = 0 ]; then
		return;
	fi
	
#	rtl_check_wlan_band
	rtl_start_wlan
	rtl_start_wps
	rtl_start_iwcontrol
}

rtl_wlanapp
