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

reg_id_text=`nv get reg_id`
dl_url_text=`nv get app_dl_url`

device_qrcode_name="/etc_rw/zcore/system/qrcode_devid.png"
appdl_qrcode_name="/etc_rw/zcore/system/qrcode_appdl.png"


echo "device_qrcode_name=$device_qrcode_name"
   
echo "enter the device id qrcode create"


rm -rf  $device_qrcode_name
rm -rf  $appdl_qrcode_name

qrencode -o $appdl_qrcode_name -m 1 -s 7 "$dl_url_text"
qrencode -o $device_qrcode_name -m 1 -s 7 "$reg_id_text"


