#!/bin/sh 
## 
# $Id: zte_qrcode_create.sh,v 0.0.0.1 2013.05.06 liuweipeng Exp $ 
# 
# usage: zte_qrcode_create.sh
# 

#wifi_ssid_qrcode_name='/usr/zte_web/web/img/qrcode_ssid_wifikey.png'
#wifi_ssid_qrcode_name_bmp='/usr/zte/zte_conf/mmi/mmi_image/ssid_wifikey.bmp'

#multi_wifi_ssid_qrcode_name='/usr/zte_web/web/img/qrcode_multi_ssid_wifikey.png'
#multi_wifi_ssid_qrcode_name_bmp='/usr/zte/zte_conf/mmi/mmi_image/multi_ssid_wifikey.bmp'

#local_domain_qrcode_name='/usr/zte_web/web/img/qrcode_local_domaind.png'
#local_domain_qrcode_name_bmp='/usr/zte/zte_conf/mmi/mmi_image/local_domaind.bmp'

ROOT=`nv get wifi_root_dir`

wifi_ssid_qrcode_name="$ROOT/wifi/qrcode_ssid_wifikey.png"
wifi_ssid_qrcode_name_bmp="$ROOT/wifi/ssid_wifikey.bmp"

multi_wifi_ssid_qrcode_name="$ROOT/wifi/qrcode_multi_ssid_wifikey.png"
multi_wifi_ssid_qrcode_name_bmp="$ROOT/wifi/multi_ssid_wifikey.bmp"

local_domain_qrcode_name="$ROOT/wifi/qrcode_local_domaind.png"
local_domain_qrcode_name_bmp="$ROOT/wifi/local_domaind.bmp"

#target_web_dir="$ROOT/securefs/web/img/"

#if [ "$ROOT" = "" ]; then
#    target_web_dir="/etc_ro/web/img/"
#else
#    target_web_dir="$ROOT/etc/web/img/"
#fi

echo "wifi_ssid_qrcode_name=$wifi_ssid_qrcode_name"
echo "wifi_ssid_qrcode_name_bmp=$wifi_ssid_qrcode_name_bmp"
############zte qrcode create shell entry#################

case $1 in 
 "wifi_create") 
   
 	echo "enter the wifi_create function"
	
	rm -rf  $wifi_ssid_qrcode_name
	rm -rf  $wifi_ssid_qrcode_name_bmp
	
	#wifi_ssid_name=`zte_nvc_apps read SSID1`	 # wifi ssid 
	#wifi_auth_mode=`zte_nvc_apps read AuthMode`  # wifi auth mode 
	#wifi_encry_type=`zte_nvc_apps read EncrypType` #wifi encry type
	#wifi_password=`zte_nvc_apps read WPAPSK1`  #wifi password
    	wifi_ssid_name=`nv get SSID1`	 # wifi ssid 
	wifi_auth_mode=`nv get AuthMode`    # wifi auth mode
	wifi_encry_type=`nv get EncrypType`  # wifi encry type
	auth_wpa=`echo $wifi_auth_mode | sed  -n '/WPA/p'`
	
	if [ -n "$auth_wpa" ];then  # wpa
		wifi_password=`nv get WPAPSK1`     # wifi password
		qrcode_text='WIFI:T:WPA;S:'$wifi_ssid_name';P:'$wifi_password';'
		echo "qrcode_text = $qrcode_text"
	elif [ "$wifi_encry_type" = "WEP" -o "$wifi_auth_mode" = "SHARED" -o "$wifi_auth_mode" = "WEPAUTO" ];then
		defaultKeyID=`nv get DefaultKeyID`
		if [ "$defaultKeyID" = "0" ];then
			wifi_password=`nv get Key1Str1`
		elif [ "$defaultKeyID" = "1" ];then
			wifi_password=`nv get Key2Str1`
		elif [ "$defaultKeyID" = "2" ];then
			wifi_password=`nv get Key3Str1`
		elif [ "$defaultKeyID" = "3" ];then
			wifi_password=`nv get Key4Str1`
		else
			wifi_password=`nv get Key1Str1`
		fi
		qrcode_text='WIFI:T:WEP;S:'$wifi_ssid_name';P:'$wifi_password';'
		echo "qrcode_text = $qrcode_text"
	elif [ "$wifi_encry_type" = "NONE" ];then
		qrcode_text='WIFI:S:'$wifi_ssid_name';'
		echo "qrcode_text = $qrcode_text"	
	fi
	
	qrencode -o $wifi_ssid_qrcode_name -m 10 -s 2 "$qrcode_text"
	png2bmp -O $wifi_ssid_qrcode_name_bmp $wifi_ssid_qrcode_name 
	
#	cp $wifi_ssid_qrcode_name $target_web_dir
	
	;;
 
 "multi_wifi_create") 
	echo "enter the multi_wifi_create function"
	
	rm -rf  $multi_wifi_ssid_qrcode_name_bmp
	rm -rf  $multi_wifi_ssid_qrcode_name
	
	#multi_wifi_ssid_name=`zte_nvc_apps read m_SSID`	  # multi wifi ssid 
	#multi_wifi_auth_mode=`zte_nvc_apps read m_AuthMode`  #multi wifi auth mode 
	#multi_wifi_encry_type=`zte_nvc_apps read m_EncrypType` #multi wifi encry type
	#multi_wifi_password=`zte_nvc_apps read m_WPAPSK1`  #multi wifi password
	multi_wifi_ssid_name=`nv get m_SSID`	 # wifi ssid 
	multi_wifi_auth_mode=`nv get m_AuthMode`    # wifi auth mode
	multi_wifi_encry_type=`nv get m_EncrypType`   # wifi encry type
	multi_wifi_password=`nv get m_WPAPSK1`      # wifi password
	auth_wpa=`echo $multi_wifi_auth_mode | sed  -n '/WPA/p'`
	
	if [ -n "$auth_wpa" ];then  # wpa
		qrcode_text='WIFI:T:WPA;S:'$multi_wifi_ssid_name';P:'$multi_wifi_password';'
		echo "qrcode_text = $qrcode_text"
	##elif [ "$multi_wifi_encry_type" = "WEP" ];then
	elif [ "$multi_wifi_encry_type" = "WEP" -o "$multi_wifi_auth_mode" = "SHARED" -o "$multi_wifi_auth_mode" = "WEPAUTO" ];then
	    multi_defaultKeyID=`nv get m_DefaultKeyID`
		if [ "$multi_defaultKeyID" = "0" ];then
			multi_wifi_password=`nv get m_Key1Str1`
		elif [ "$multi_defaultKeyID" = "1" ];then
			multi_wifi_password=`nv get m_Key2Str1`
		elif [ "$multi_defaultKeyID" = "2" ];then
			multi_wifi_password=`nv get m_Key3Str1`
		elif [ "$multi_defaultKeyID" = "3" ];then
			multi_wifi_password=`nv get m_Key4Str1`
		else
			multi_wifi_password=`nv get m_Key1Str1`
		fi		  	 	 
		qrcode_text='WIFI:T:WEP;S:'$multi_wifi_ssid_name';P:'$multi_wifi_password';'
		echo "qrcode_text = $qrcode_text"
	elif [ "$multi_wifi_encry_type" = "NONE" ];then
		qrcode_text='WIFI:S:'$multi_wifi_ssid_name';'
		echo "qrcode_text = $qrcode_text"	
	fi
	
	qrencode -o $multi_wifi_ssid_qrcode_name -m 10 -s 2 "$qrcode_text"
	png2bmp  -O $multi_wifi_ssid_qrcode_name_bmp $multi_wifi_ssid_qrcode_name
	
#	cp $multi_wifi_ssid_qrcode_name $target_web_dir
	;;
	
 "local_domain_create") 
	echo "enter the local_url_create function"
	
	rm -rf  $local_domain_qrcode_name_bmp
	
	local_domain_url=`zte_nvc_apps read LocalDomain`	  #local domain name
	local_domain_username=`zte_nvc_apps read admin_user`  #local domain username
	local_domain_passwd=`zte_nvc_apps read admin_Password` #local domain password	
 
	qrcode_text='http://'$local_domain_url
	echo "qrcode_text = $qrcode_text"	
		
	qrencode -o $local_domain_qrcode_name -m 10 -s 2 "$qrcode_text"
	png2bmp  -O $local_domain_qrcode_name_bmp  $local_domain_qrcode_name
	
	local_domain_qrcode_name
 
	;;
esac