#!/bin/sh 




ROOT=`nv get wifi_root_dir`

wifi_ssid_qrcode_name="$ROOT/wifi/qrcode_ssid_wifikey.png"
wifi_ssid_qrcode_name_bmp="$ROOT/wifi/ssid_wifikey.bmp"

multi_wifi_ssid_qrcode_name="$ROOT/wifi/qrcode_multi_ssid_wifikey.png"
multi_wifi_ssid_qrcode_name_bmp="$ROOT/wifi/multi_ssid_wifikey.bmp"

local_domain_qrcode_name="$ROOT/wifi/qrcode_local_domaind.png"
local_domain_qrcode_name_bmp="$ROOT/wifi/local_domaind.bmp"



echo "wifi_ssid_qrcode_name=$wifi_ssid_qrcode_name"
echo "wifi_ssid_qrcode_name_bmp=$wifi_ssid_qrcode_name_bmp"

case $1 in 
 "wifi_create") 

 	echo "enter the wifi_create function"

	rm -rf  $wifi_ssid_qrcode_name
	rm -rf  $wifi_ssid_qrcode_name_bmp

    	wifi_ssid_name=`nv get SSID1`	 # wifi ssid 
	wifi_auth_mode=`nv get AuthMode`    # wifi auth mode
	wifi_encry_type=`nv get EncrypType`  # wifi encry type
	auth_wpa=`echo $wifi_auth_mode | sed  -n '/WPA/p'`
	auth_wpa_1=`echo $wifi_auth_mode | sed  -n '/WPA3/p'`
	if [ -n "$auth_wpa" ];then  # wpa
		wifi_password=`nv get WPAPSK1`     # wifi password
		if [ -n "$auth_wpa_1" ];then
			wifi_T="SAE"
		else
			wifi_T="WPA"
		fi
		qrcode_text='WIFI:T:'$wifi_T';S:'$wifi_ssid_name';P:'$wifi_password';'
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

	showmode=`nv get mmi_showmode`
	lcd_size=`nv get remo_lcd_size`
	echo "ray, showmode = $showmode"
	if [ "x$showmode" == "xlcd" ]; then
		if [ "x$lcd_size" == "x128x160" ]; then	#add by darren.zhang 2023.03.30 R1878项目使用128x160尺寸屏幕
			qrencode -o $wifi_ssid_qrcode_name -m 5 -s 2 "$qrcode_text"
		else
			qrencode -o $wifi_ssid_qrcode_name -m 10 -s 2 "$qrcode_text"
		fi
	else
		qrencode -o $wifi_ssid_qrcode_name -m 2 -s 2 "$qrcode_text"
	fi
	png2bmp -O $wifi_ssid_qrcode_name_bmp $wifi_ssid_qrcode_name 


	;;

 "multi_wifi_create") 
	echo "enter the multi_wifi_create function"

	rm -rf  $multi_wifi_ssid_qrcode_name_bmp
	rm -rf  $multi_wifi_ssid_qrcode_name

	multi_wifi_ssid_name=`nv get m_SSID`	 # wifi ssid 
	multi_wifi_auth_mode=`nv get m_AuthMode`    # wifi auth mode
	multi_wifi_encry_type=`nv get m_EncrypType`   # wifi encry type
	multi_wifi_password=`nv get m_WPAPSK1`      # wifi password
	auth_wpa=`echo $multi_wifi_auth_mode | sed  -n '/WPA/p'`
	auth_wpa_1=`echo $multi_wifi_auth_mode | sed  -n '/WPA3/p'`
	if [ -n "$auth_wpa" ];then  # wpa
		if [ -n "$auth_wpa_1" ];then
			wifi_T="SAE"
		else
			wifi_T="WPA"
		fi
		qrcode_text='WIFI:T:'$wifi_T';S:'$multi_wifi_ssid_name';P:'$multi_wifi_password';'
		echo "qrcode_text = $qrcode_text"
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

	showmode=`nv get mmi_showmode`
	if [ "x$showmode" == "xlcd" ]; then
		qrencode -o $multi_wifi_ssid_qrcode_name -m 10 -s 2 "$qrcode_text"
	else
		qrencode -o $multi_wifi_ssid_qrcode_name -m 2 -s 2 "$qrcode_text"
	fi
	png2bmp  -O $multi_wifi_ssid_qrcode_name_bmp $multi_wifi_ssid_qrcode_name

	;;

 "local_domain_create") 
	echo "enter the local_url_create function"

	rm -rf  $local_domain_qrcode_name_bmp

	local_domain_url=`zte_nvc_apps read LocalDomain`	  #local domain name
	local_domain_username=`zte_nvc_apps read admin_user`  #local domain username
	local_domain_passwd=`zte_nvc_apps read admin_Password` #local domain password	

	qrcode_text='http://'$local_domain_url
	echo "qrcode_text = $qrcode_text"	

	showmode=`nv get mmi_showmode`
	if [ "x$showmode" == "xlcd" ]; then
		qrencode -o $local_domain_qrcode_name -m 10 -s 2 "$qrcode_text"
	else
		qrencode -o $local_domain_qrcode_name -m 2 -s 2 "$qrcode_text"
	fi		
	png2bmp  -O $local_domain_qrcode_name_bmp  $local_domain_qrcode_name

	local_domain_qrcode_name

	;;
esac