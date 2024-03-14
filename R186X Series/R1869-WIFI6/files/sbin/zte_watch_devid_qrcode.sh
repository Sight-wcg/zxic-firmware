#!/bin/sh 




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


