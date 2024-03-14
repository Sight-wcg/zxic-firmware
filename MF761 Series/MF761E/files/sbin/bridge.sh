#!/bin/sh
#
# script file to start bridge
#
# Usage: bridge.sh br_interface lan1_interface wlan_interface[1]..wlan_interface[N]
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


if [ $# -lt 2 ]; then
	echo "Usage: $0 br_interface lan1_interface wlan_interface ..."  >> $LOG
	exit $ERROR_INVALID_PARAMETERS;
fi


ROOT=`nv get wifi_root_dir`
LOG=$ROOT/wifi/realtek/slog
#CUR_PATH=`pwd`
CONFIG_ROOT_DIR="$ROOT/wifi/realtek/rtl8192c"

if [ -z "$WLAN_PREFIX" ]; then
	WLAN_PREFIX=wlan
fi

LAN_PREFIX=eth
BR_UTIL=brctl
IFCONFIG=ifconfig
SLEEP=sleep
## test for to RESTART_BR be 1
RESTART_BR=0
RESTART_LAN=0
RESTART_WLAN=1

#set PARA for $i can't pass to function
BR_INTF=$1
PARA2=$2
PARA3=$3
PARA_ALL=$*

BR_NOT_EXIST=0

rtl_shutdown_net_if() {
	if [ $BR_NOT_EXIST != 0 ]; then
		return;
	fi
	
	# shutdown network interface (ethernet, wlan)
	for ARG in $PARA_ALL ; do
		case $ARG in
		$LAN_PREFIX*)
			if [ $RESTART_LAN != 0 ]; then
				$IFCONFIG $ARG down	
				$BR_UTIL delif $BR_INTF $ARG 2> /dev/null
			fi
			;;
		$WLAN_PREFIX*)
			if [ $RESTART_WLAN != 0 ]; then
				$IFCONFIG $ARG down	
				$BR_UTIL delif $BR_INTF $ARG 2> /dev/null
			fi
			;;
		*)
			;;
		esac
	done
}

rtl_enable_net_if() {
	# Enable network interface (Ethernet, wlan, WDS, bridge)
	if [ $RESTART_BR != 0 ]; then
		echo 'Setup bridge...'  >> $LOG
		if [ $BR_NOT_EXIST != 0 ]; then
			$BR_UTIL addbr $BR_INTF
			if [ $? != 0 ]; then
				echo "Failed: $BR_UTIL addbr $BR_INTF"
				exit $ERROR_ADD_BR_FAIL;
			fi
		fi
		#$BR_UTIL setfd $BR_INTF 0
		#$BR_UTIL stp $BR_INTF 0
	fi
	#IP_ADDR=`cat $CONFIG_ROOT_DIR/ip_addr`
	#SUBNET_MASK=`cat $CONFIG_ROOT_DIR/net_mask`
	#$IFCONFIG $BR_INTF $IP_ADDR netmask $SUBNET_MASK
	
	#Add lan port to bridge interface
	if [ $RESTART_LAN != 0 ]; then
		for ARG in $PARA_ALL ; do
			case $ARG in
			$LAN_PREFIX*)
				$BR_UTIL addif $BR_INTF $ARG 2> /dev/null
				$IFCONFIG $ARG  0.0.0.0
				;;
			*)
				;;
			esac
		done
	fi
	
	if [ $RESTART_WLAN != 0 ]; then
		for ARG in $PARA_ALL ; do
			case $ARG in
			$WLAN_PREFIX*)
				CONFIG_DIR=$CONFIG_ROOT_DIR/$ARG
				WLAN_DISABLED_VALUE=`cat $CONFIG_DIR/wlan_disabled`
				echo "$CONFIG_DIR/wlan_disabled = $WLAN_DISABLED_VALUE " >> $LOG
				
				ISUP=`$IFCONFIG $ARG | grep UP`
				if [ "$WLAN_DISABLED_VALUE" = 0  -a  "$ISUP" = "" ]; then
				
					echo "$IFCONFIG $ARG up"  >> $LOG
					$IFCONFIG $ARG up					
					if [ $? != 0 ]; then
						echo "$IFCONFIG $ARG up failed "  >> $LOG
						exit $ERROR_NET_IF_UP_FAIL;
					fi
				
				
					if [ "$ARG" != "wlan0" -a "$ARG" != "wlan0-vxd" ]; then
						HAS_BEEN_ADDED=`$BR_UTIL show | grep $ARG`
						if [ ! -z "$HAS_BEEN_ADDED" ]; then
							echo "$ARG  has been added to $BR_UTIL :: $HAS_BEEN_ADDED"  >> $LOG
						else
							echo "$ARG  has not been added to $BR_UTIL :: $HAS_BEEN_ADDED"  >> $LOG
							echo "$BR_UTIL addif $BR_INTF $ARG" >> $LOG
							$BR_UTIL addif $BR_INTF $ARG 2> /dev/null
							
							if [ $? != 0 ]; then
								echo "Failed: $BR_UTIL addif $BR_INTF $ARG"  >> $LOG
								exit $ERROR_ADD_IF_FAIL;
							fi
					
						fi
						

						#IP_ADDR=`cat $CONFIG_DIR/ip_addr`
						#$IFCONFIG $ARG $IP_ADDR
						$IFCONFIG $ARG 0.0.0.0
					fi

					#$SLEEP 1
				fi
				;;
			*)
				;;
			esac
		done
	fi
}
#end of rtl_enable_net_if

rtl_bridge() {
	BR_NOT_EXIST=`$IFCONFIG $BR_INTF > /dev/null 2>&1; echo $?`
	if [ "$PARA3" != "null" ]; then
		#rtl_shutdown_net_if
		rtl_enable_net_if
	fi
}


rtl_bridge

