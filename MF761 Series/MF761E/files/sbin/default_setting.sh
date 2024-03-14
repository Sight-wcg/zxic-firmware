#!/bin/sh

## error code


ERROR_SUCCESS=0
ERROR_INVALID_PARAMETERS=1

if [ $# -lt 1 ]; then echo "Usage: $0 iface"; exit 1; fi
ROOT=`nv get wifi_root_dir`
CONFIG_ROOT_DIR="$ROOT/wifi/realtek/rtl8192c"
CONFIG_DIR=$CONFIG_ROOT_DIR/$1

if [ ! -d "$CONFIG_ROOT_DIR" ]; then
    mkdir -p $CONFIG_ROOT_DIR
fi

if [ ! -d "$CONFIG_DIR" ]; then
    mkdir -p $CONFIG_DIR
fi

if [ ! -f "$CONFIG_ROOT_DIR/wifi_script_dir" ]; then
	echo "/sbin" > $CONFIG_ROOT_DIR/wifi_script_dir
fi
if [ ! -f "$CONFIG_ROOT_DIR/wifi_bin_dir" ]; then
	echo "/bin" > $CONFIG_ROOT_DIR/wifi_bin_dir
fi

WLAN_PREFIX=wlan

case $1 in
$WLAN_PREFIX[0-9]*)
	EXT=${1#$WLAN_PREFIX[0-9]}
	echo $EXT
	;;
*)
	echo "invalid WLAN interface!($1)"
	exit $ERROR_INVALID_PARAMETERS
	;;
esac

echo "1" > $CONFIG_DIR/board_ver
echo "00017301FA10" > $CONFIG_DIR/nic0_addr
echo "00017301FA19" > $CONFIG_DIR/nic1_addr
echo "00017301FA10" > $CONFIG_DIR/wlan0_addr
echo "00017301FA11" > $CONFIG_DIR/wlan1_addr
echo "00017301FA12" > $CONFIG_DIR/wlan2_addr
echo "00017301FA13" > $CONFIG_DIR/wlan3_addr
echo "00017301FA14" > $CONFIG_DIR/wlan4_addr
echo "00017301FA15" > $CONFIG_DIR/wlan5_addr
echo "00017301FA16" > $CONFIG_DIR/wlan6_addr
echo "00017301FA17" > $CONFIG_DIR/wlan7_addr

echo "0000000000000000000000000000" > $CONFIG_DIR/tx_power_cck_a
echo "0000000000000000000000000000" > $CONFIG_DIR/tx_power_cck_b
echo "0000000000000000000000000000" > $CONFIG_DIR/tx_power_ht40_1s_a
echo "0000000000000000000000000000" > $CONFIG_DIR/tx_power_ht40_1s_b
echo "0000000000000000000000000000" > $CONFIG_DIR/tx_power_diff_ht40_2s
echo "0000000000000000000000000000" > $CONFIG_DIR/tx_power_diff_ht20
echo "0000000000000000000000000000" > $CONFIG_DIR/tx_power_diff_ofdm
echo "3" > $CONFIG_DIR/reg_domain
echo "0" > $CONFIG_DIR/11n_xcap
echo "0" > $CONFIG_DIR/led_type
echo "0" > $CONFIG_DIR/tssi_1
echo "0" > $CONFIG_DIR/tssi_2
echo "0" > $CONFIG_DIR/11n_ther
echo "0" > $CONFIG_DIR/trswitch

#wlan_mode: 0: AP, 1: Clienr(network_type=0)/AD-Hoc(network_type=1) 
echo "0" >  $CONFIG_DIR/wlan_mode
echo "0" >  $CONFIG_DIR/wlan_disabled
echo "family-test$EXT" > $CONFIG_DIR/ssid
echo "3" > $CONFIG_DIR/MIMO_TR_mode

#channel: default channel
echo "1" > $CONFIG_DIR/channel
#ch_hi: Available highest channel
echo "0" > $CONFIG_DIR/ch_hi
#ch_low: Available lowest channel
echo "0" > $CONFIG_DIR/ch_low
#band: 64: 11AC, 8: 11N, 4: 11A, 2: 11G, 1: 11B; ex. 11 = 8 + 2 + 1 => BGN mode
echo "11" > $CONFIG_DIR/band
#basic_rate: 15=0x0f -> bit0-bit11 as 1,2,5.5,11,6,9,12,18,24,36,48,54
echo "15" > $CONFIG_DIR/basic_rates
echo "4095" > $CONFIG_DIR/supported_rate
echo "1" > $CONFIG_DIR/rate_adaptive_enabled
echo "0" > $CONFIG_DIR/fix_rate
echo "2347" > $CONFIG_DIR/rts_threshold
echo "2346" > $CONFIG_DIR/frag_threshold
echo "30000" >  $CONFIG_DIR/inactivity_time	#unit:10ms
echo "100" > $CONFIG_DIR/beacon_interval
echo "1" > $CONFIG_DIR/dtim_period
echo "0" > $CONFIG_DIR/preamble_type
echo "0" > $CONFIG_DIR/hidden_ssid
echo "0" > $CONFIG_DIR/supported_sta_num
echo "1" > $CONFIG_DIR/protection_disabled
echo "0" > $CONFIG_DIR/macclone_enable
echo "0" > $CONFIG_DIR/iapp_enable
echo "2" > $CONFIG_DIR/wifi_specific
echo "0" > $CONFIG_DIR/vap_enable
echo "0" > $CONFIG_DIR/group_id
echo "0" > $CONFIG_DIR/block_relay
echo "1" > $CONFIG_DIR/wmm_enabled
echo "0" > $CONFIG_DIR/guest_access

echo "0" > $CONFIG_DIR/wds_enable
echo "0" > $CONFIG_DIR/wds_pure

echo "0" > $CONFIG_DIR/macac_enabled
echo "0" > $CONFIG_DIR/macac_num
#echo "001122334455" > $CONFIG_DIR/macac_addr1
#echo "001234567890" > $CONFIG_DIR/macac_addr2

echo "0" > $CONFIG_DIR/countrycode_enable
echo "US" > $CONFIG_DIR/countrycode

echo "0" > $CONFIG_DIR/wapiType
echo "1234567890" > $CONFIG_DIR/wapiPsk
echo "a" > $CONFIG_DIR/wapiPsklen
echo "2" > $CONFIG_DIR/auth_type
echo "0" > $CONFIG_DIR/encrypt
echo "2" > $CONFIG_DIR/wpa_auth
echo "87654321" > $CONFIG_DIR/wpa_psk
echo "2" > $CONFIG_DIR/wpa_cipher
echo "2" > $CONFIG_DIR/wpa2_cipher
echo "0" > $CONFIG_DIR/psk_enable
echo "86400" > $CONFIG_DIR/gk_rekey
echo "0" > $CONFIG_DIR/psk_format

echo "0" > $CONFIG_DIR/wep
echo "0" > $CONFIG_DIR/wep_default_key
echo "1" > $CONFIG_DIR/wep_key_type
echo "0987654321" > $CONFIG_DIR/wepkey1_64_hex
echo "0987654321" > $CONFIG_DIR/wepkey2_64_hex
echo "0987654321" > $CONFIG_DIR/wepkey3_64_hex
echo "0987654321" > $CONFIG_DIR/wepkey4_64_hex
echo "3534333231" > $CONFIG_DIR/wepkey1_64_asc
echo "3534333231" > $CONFIG_DIR/wepkey2_64_asc
echo "3534333231" > $CONFIG_DIR/wepkey3_64_asc
echo "3534333231" > $CONFIG_DIR/wepkey4_64_asc
echo "12345678901234567890123456" > $CONFIG_DIR/wepkey1_128_hex
echo "12345678901234567890123456" > $CONFIG_DIR/wepkey2_128_hex
echo "12345678901234567890123456" > $CONFIG_DIR/wepkey3_128_hex
echo "12345678901234567890123456" > $CONFIG_DIR/wepkey4_128_hex
echo "31323334353637383930313233" > $CONFIG_DIR/wepkey1_128_asc
echo "31323334353637383930313233" > $CONFIG_DIR/wepkey2_128_asc
echo "31323334353637383930313233" > $CONFIG_DIR/wepkey3_128_asc
echo "31323334353637383930313233" > $CONFIG_DIR/wepkey4_128_asc
#network_type: 0 - Client mode, 1 - AD-Hoc mode
echo "0" > $CONFIG_DIR/network_type
echo "" > $CONFIG_DIR/default_ssid
echo "0" > $CONFIG_DIR/power_scale

# channel_bonding: BW: 0 - 20M mode, 1 - 40M, 2 - 80M mode
echo "0" > $CONFIG_DIR/channel_bonding
#control_sideband: BW: 0 - lower 2nd channel offset , 1 - higher 2nd channel offset
echo "0" > $CONFIG_DIR/control_sideband
echo "1" > $CONFIG_DIR/aggregation
echo "1" > $CONFIG_DIR/short_gi
echo "0" > $CONFIG_DIR/stbc_enabled
echo "0" > $CONFIG_DIR/coexist_enabled

echo "0" > $CONFIG_DIR/enable_1x
echo "0.0.0.0" > $CONFIG_DIR/rs_ip
echo "1812" > $CONFIG_DIR/rs_port
echo "" > $CONFIG_DIR/rs_password
echo "3" > $CONFIG_DIR/rs_maxretry
echo "5" > $CONFIG_DIR/rs_interval_time
echo "0" > $CONFIG_DIR/mac_auth_enabled
echo "0" > $CONFIG_DIR/enable_supp_nonwpa
echo "0" > $CONFIG_DIR/supp_nonwpa
echo "0" > $CONFIG_DIR/wpa2_pre_auth

echo "0" > $CONFIG_DIR/account_rs_enabled
echo "0.0.0.0" > $CONFIG_DIR/account_rs_ip
echo "0" > $CONFIG_DIR/account_rs_port
echo "" > $CONFIG_DIR/account_rs_password
echo "0" > $CONFIG_DIR/account_rs_update_enabled
echo "0" > $CONFIG_DIR/account_rs_update_delay
echo "0" > $CONFIG_DIR/account_rs_maxretry
echo "0" > $CONFIG_DIR/account_rs_interval_time

echo "0" > $CONFIG_DIR/wsc_disabled
echo "3" > $CONFIG_DIR/wsc_method
echo "0" > $CONFIG_DIR/wsc_configured
echo "1" > $CONFIG_DIR/wsc_auth
echo "1" > $CONFIG_DIR/wsc_enc
echo "0" > $CONFIG_DIR/wsc_manual_enabled
echo "1" > $CONFIG_DIR/wsc_upnp_enabled
echo "1" > $CONFIG_DIR/wsc_registrar_enabled
echo "" > $CONFIG_DIR/wsc_ssid
echo "" > $CONFIG_DIR/wsc_psk
echo "0" > $CONFIG_DIR/wsc_configbyextreg
echo "27006672" > $CONFIG_DIR/wsc_pin

echo "0.0.0.0" > $CONFIG_DIR/ip_addr
echo "255.255.255.0" > $CONFIG_DIR/net_mask

echo "192.168.1.250" > $CONFIG_ROOT_DIR/ip_addr
echo "255.255.255.0" > $CONFIG_ROOT_DIR/net_mask
echo "RTL8192CD" > $CONFIG_ROOT_DIR/device_name
echo "0" > $CONFIG_ROOT_DIR/band2g5g_select
