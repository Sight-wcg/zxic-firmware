#!/bin/sh
#
# script file to start WLAN
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

ROOT=`nv get wifi_root_dir`
LOG=$ROOT/wifi/realtek/slog

IWPRIV=iwpriv
wifi_lte_intr=`nv get wifi_lte_intr`

if [ $# -lt 1 ]; then
	echo "Usage: $0 wlan_interface" >> $LOG
	exit $ERROR_INVALID_PARAMETERS;
fi

date +[%H:%M:%S]paraset_$1_start >> $LOG

CONFIG_ROOT_DIR="$ROOT/wifi/realtek/rtl8192c"
CONFIG_DIR=$CONFIG_ROOT_DIR/$1

if [ ! -d "$CONFIG_DIR" ]; then
	echo "$CONFIG_DIR: No such directory" >> $LOG
	exit $ERROR_NO_CONFIG_FILE
fi

if [ -z "$WLAN_PREFIX" ]; then
	WLAN_PREFIX=wlan
fi

if [ -z "$ROOT_WLAN" ]; then
#	ROOT_WLAN=${1:0:$WLAN_NAME_LEN}
### delete -va0 get wlan0
	ROOT_WLAN=${1%%-*}  
fi
ROOT_CONFIG_DIR=$CONFIG_ROOT_DIR/$ROOT_WLAN

IS_ROOT_WLAN=0
if [ "$1" = "$ROOT_WLAN" ]; then
	IS_ROOT_WLAN=1
fi
echo "IS_ROOT_WLAN is " $IS_ROOT_WLAN
SET_WLAN="iwpriv $1"
SET_WLAN_PARAM="$SET_WLAN set_mib"
IFCONFIG=ifconfig


$IFCONFIG $1 down
if [ $? != 0 ]; then
	exit $ERROR_NO_SUCH_DEVICE
fi


echo "set RF parameters" >> $LOG
# set RF parameters


# set channel
	GET_VALUE=`cat $CONFIG_DIR/channel`
	$SET_WLAN set_mib channel=$GET_VALUE

##autochannel can use wifi_lte_intr
	if [ "$wifi_lte_intr" = "1" -a "$GET_VALUE" = "0" ];then
		echo "wifi_lte_intr=$wifi_lte_intr  $SET_WLAN set_mib ch_low=5" >> $LOG	
#		$SET_WLAN set_mib ch_low=5
		$SET_WLAN set_mib disable_acs_ch=15
	else
		GET_VALUE=`cat $CONFIG_DIR/ch_low`
		$SET_WLAN set_mib ch_low=$GET_VALUE
	fi

# set wifi coverage	
	GET_TX_POWER_PERCENT=`cat $CONFIG_DIR/tx_power_percet`
	#echo "GET_TX_POWER_PERCENT is "$GET_TX_POWER_PERCENT
	$SET_WLAN set_mib powerpercent=$GET_TX_POWER_PERCENT
	
# for country code
	COUNTRY_CODE_ENABLE=`$SET_WLAN get_mib countrycode 2> /dev/null`
	if [ ! -z "$COUNTRY_CODE_ENABLE" ]; then
		GET_VALUE=`cat $ROOT_CONFIG_DIR/countrycode_enable`
		$SET_WLAN set_mib countrycode=$GET_VALUE

		GET_VALUE=`cat $ROOT_CONFIG_DIR/countrycode`
		$SET_WLAN set_mib countrystr=$GET_VALUE
	fi
	
	
#set band	  bgn
	GET_BAND=`cat $ROOT_CONFIG_DIR/band`
	GET_WIFI_SPECIFIC=`cat $ROOT_CONFIG_DIR/wifi_specific`
	if [ "$GET_VALUE_WLAN_MODE" != '1' ] && [ "$GET_WIFI_SPECIFIC" = 1 ] &&  [ "$GET_BAND" = '2' ] ; then
		GET_BAND=3
	fi
	if [ "$GET_BAND" = '8' ]; then
		GET_BAND=11
		$SET_WLAN set_mib deny_legacy=3
	elif [ "$GET_BAND" = '2' ]; then
		GET_BAND=3
		$SET_WLAN set_mib deny_legacy=1
	elif [ "$GET_BAND" = '10' ]; then
		GET_BAND=11
		$SET_WLAN set_mib deny_legacy=1
	elif [ "$GET_BAND" = '64' ]; then
		GET_BAND=76
		$SET_WLAN set_mib deny_legacy=12
	elif [ "$GET_BAND" = '72' ]; then
		GET_BAND=76
		$SET_WLAN set_mib deny_legacy=4
	else
		$SET_WLAN set_mib deny_legacy=0
	fi
	
	$SET_WLAN set_mib band=$GET_BAND	


###Set 11n parameter
		if [ $GET_BAND = 10 ] || [ $GET_BAND = 11 ] || [ $GET_BAND = 76 ]; then
			if [ $IS_ROOT_WLAN = 1 ]; then
				GET_CHANNEL_BONDING=`cat $CONFIG_DIR/channel_bonding`
				$SET_WLAN set_mib use40M=$GET_CHANNEL_BONDING

				GET_CONTROL_SIDEBAND=`cat $CONFIG_DIR/control_sideband`

				if [ "$GET_CHANNEL_BONDING" = 0 ]; then
					$SET_WLAN set_mib 2ndchoffset=0
				else
					if [ "$GET_CONTROL_SIDEBAND" = 0 ]; then
						 $SET_WLAN set_mib 2ndchoffset=1
					fi
					if [ "$GET_CONTROL_SIDEBAND" = 1 ]; then
						 $SET_WLAN set_mib 2ndchoffset=2
					fi
				fi
			fi # [ $IS_ROOT_WLAN = 1 ]

		GET_COEXIST_ENABLED=`cat $CONFIG_DIR/coexist_enabled`
		$SET_WLAN set_mib coexist=$GET_COEXIST_ENABLED
		fi # [ $GET_BAND = 10 ] || [ $GET_BAND = 11 ]
##########
	

## for wlan0 set ssid 
echo "set basic ap parameters" >> $LOG
	GET_VALUE=`cat $CONFIG_DIR/ssid`
	$SET_WLAN set_mib ssid="$GET_VALUE"
	
	GET_VALUE=`cat $CONFIG_DIR/hidden_ssid`
	$SET_WLAN set_mib hiddenAP=$GET_VALUE

	GET_VALUE=`cat $CONFIG_DIR/supported_sta_num`
	$SET_WLAN set_mib stanum=$GET_VALUE

	# for ap isolation 
	# need to confirm which is for ap isolation
	#GET_VALUE=`cat $CONFIG_DIR/group_id`
	#$SET_WLAN set_mib groupID=$GET_VALUE

	# set block relay
	GET_VALUE=`cat $CONFIG_DIR/block_relay`
	$SET_WLAN set_mib block_relay=$GET_VALUE


	GET_WLAN_AUTH_TYPE=`cat $CONFIG_DIR/auth_type`
	AUTH_TYPE=$GET_WLAN_AUTH_TYPE
	GET_WLAN_ENCRYPT=`cat $CONFIG_DIR/encrypt`
	if [ "$GET_WLAN_AUTH_TYPE" = '1' ] && [ "$GET_WLAN_ENCRYPT" != '1' ]; then
		# shared-key and not WEP enabled, force to open-system
		AUTH_TYPE=0
	fi
	$SET_WLAN set_mib authtype=$AUTH_TYPE
	if [ "$GET_WLAN_ENCRYPT" = '0' ]; then
		$SET_WLAN set_mib encmode=0
	elif [ "$GET_WLAN_ENCRYPT" = '1' ]; then
		### WEP mode ##
		GET_WEP=`cat $CONFIG_DIR/wep`
		GET_WEP_KEY_TYPE=`cat $CONFIG_DIR/wep_key_type`
		GET_WEP_KEY_ID=`cat $CONFIG_DIR/wep_default_key`
		
		if [ "$GET_WEP" = '1' ]; then
			if [ "$GET_WEP_KEY_TYPE" = '0' ]; then
				GET_WEP_KEY_1=`cat $CONFIG_DIR/wepkey1_64_asc`
				GET_WEP_KEY_2=`cat $CONFIG_DIR/wepkey2_64_asc`
				GET_WEP_KEY_3=`cat $CONFIG_DIR/wepkey3_64_asc`
				GET_WEP_KEY_4=`cat $CONFIG_DIR/wepkey4_64_asc`
			else
				GET_WEP_KEY_1=`cat $CONFIG_DIR/wepkey1_64_hex`
				GET_WEP_KEY_2=`cat $CONFIG_DIR/wepkey2_64_hex`
				GET_WEP_KEY_3=`cat $CONFIG_DIR/wepkey3_64_hex`
				GET_WEP_KEY_4=`cat $CONFIG_DIR/wepkey4_64_hex`
			fi
		
			$SET_WLAN set_mib encmode=1
			$SET_WLAN set_mib wepkey1=$GET_WEP_KEY_1
			$SET_WLAN set_mib wepkey2=$GET_WEP_KEY_2
			$SET_WLAN set_mib wepkey3=$GET_WEP_KEY_3
			$SET_WLAN set_mib wepkey4=$GET_WEP_KEY_4
			$SET_WLAN set_mib wepdkeyid=$GET_WEP_KEY_ID
		else
			if [ "$GET_WEP_KEY_TYPE" = '0' ]; then
				GET_WEP_KEY_1=`cat $CONFIG_DIR/wepkey1_128_asc`
				GET_WEP_KEY_2=`cat $CONFIG_DIR/wepkey2_128_asc`
				GET_WEP_KEY_3=`cat $CONFIG_DIR/wepkey3_128_asc`
				GET_WEP_KEY_4=`cat $CONFIG_DIR/wepkey4_128_asc`
			else
				GET_WEP_KEY_1=`cat $CONFIG_DIR/wepkey1_128_hex`
				GET_WEP_KEY_2=`cat $CONFIG_DIR/wepkey2_128_hex`
				GET_WEP_KEY_3=`cat $CONFIG_DIR/wepkey3_128_hex`
				GET_WEP_KEY_4=`cat $CONFIG_DIR/wepkey4_128_hex`
			fi
			$SET_WLAN set_mib encmode=5
			$SET_WLAN set_mib wepkey1=$GET_WEP_KEY_1
			$SET_WLAN set_mib wepkey2=$GET_WEP_KEY_2
			$SET_WLAN set_mib wepkey3=$GET_WEP_KEY_3
			$SET_WLAN set_mib wepkey4=$GET_WEP_KEY_4
			$SET_WLAN set_mib wepdkeyid=$GET_WEP_KEY_ID
		fi
	else
			## WPA mode ##
		$SET_WLAN set_mib encmode=2
	fi


	## Set 802.1x flag ##
	_ENABLE_1X=0
	if [ $GET_WLAN_ENCRYPT -lt 2 ]; then
		GET_ENABLE_1X=`cat $CONFIG_DIR/enable_1x`
		GET_MAC_AUTH_ENABLED=`cat $CONFIG_DIR/mac_auth_enabled`
		if [ "$GET_ENABLE_1X" != 0 ] || [ "$GET_MAC_AUTH_ENABLED" != 0 ]; then
			_ENABLE_1X=1
		fi
	else
		_ENABLE_1X=1
	fi
	$SET_WLAN set_mib 802_1x=$_ENABLE_1X
	

	echo "wpa relative settings"  >> $LOG
#
# following settings is used when driver WPA module is included
#

	GET_WPA_AUTH=`cat $CONFIG_DIR/wpa_auth`
	#if [ $GET_VALUE_WLAN_MODE != 1 ] && [ $GET_WLAN_ENCRYPT -ge 2 ]  && [ $GET_WLAN_ENCRYPT -lt 7 ] && [ $GET_WPA_AUTH = 2 ]; then
	if [ $GET_WLAN_ENCRYPT -ge 2 ]  && [ $GET_WLAN_ENCRYPT -lt 7 ]; then
		if [ $GET_WPA_AUTH = 2 ]; then
			if [ $GET_WLAN_ENCRYPT = 2 ]; then
				ENABLE=1
			elif [ $GET_WLAN_ENCRYPT = 4 ]; then
				ENABLE=2
			elif [ $GET_WLAN_ENCRYPT = 6 ]; then
				ENABLE=3
			else
				echo "invalid ENCRYPT value!($GET_WLAN_ENCRYPT)" >> $LOG
				exit $ERROR_INVALID_PARAMETERS;
			fi
			$SET_WLAN set_mib psk_enable=$ENABLE
		else
			$SET_WLAN set_mib psk_enable=0
		fi

		if [ $GET_WLAN_ENCRYPT = 2 ] || [ $GET_WLAN_ENCRYPT = 6 ]; then
			GET_WPA_CIPHER_SUITE=`cat $CONFIG_DIR/wpa_cipher`
			if [ $GET_WPA_CIPHER_SUITE = 1 ]; then
				CIPHER=2
			elif [ $GET_WPA_CIPHER_SUITE = 2 ]; then
				CIPHER=8
			elif [ $GET_WPA_CIPHER_SUITE = 3 ]; then
				CIPHER=10
			else
				echo "invalid WPA_CIPHER_SUITE value!($GET_WPA_CIPHER_SUITE)" >> $LOG
				exit $ERROR_INVALID_PARAMETERS;
			fi
		fi
		$SET_WLAN set_mib wpa_cipher=$CIPHER

		if [ $GET_WLAN_ENCRYPT = 4 ] || [ $GET_WLAN_ENCRYPT = 6 ]; then
			GET_WPA2_CIPHER_SUITE=`cat $CONFIG_DIR/wpa2_cipher`
			if [ $GET_WPA2_CIPHER_SUITE = 1 ]; then
				CIPHER=2
			elif [ $GET_WPA2_CIPHER_SUITE = 2 ]; then
				CIPHER=8
			elif [ $GET_WPA2_CIPHER_SUITE = 3 ]; then
				CIPHER=10
			else
				echo "invalid WPA2_CIPHER_SUITE value!($GET_WPA2_CIPHER_SUITE)" >> $LOG
				exit $ERROR_INVALID_PARAMETERS;
			fi
		fi
		$SET_WLAN set_mib wpa2_cipher=$CIPHER

		GET_WPA_PSK=`cat $CONFIG_DIR/wpa_psk`
		$SET_WLAN set_mib passphrase=$GET_WPA_PSK

	fi




$IFCONFIG $1 up
if [ $? != 0 ]; then
	exit $ERROR_NO_SUCH_DEVICE
fi




exit $ERROR_SUCCESS