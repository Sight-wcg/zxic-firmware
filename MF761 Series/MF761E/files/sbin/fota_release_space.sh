#!/bin/sh

echo "Begin release space..."

#杀掉应用
killall at_ctl
killall dnsmasq
killall radvd
killall dhcp6
killall zte_ndp
killall zte_mainctrl
killall zte_hotplug
killall sntp
killall rtc-service
killall zte_audio_ctrl
killall sms
killall phonebook
#EC 616000558980
#killall zte_mmi

killall fluxstat
killall goahead
killall wpa_supplicant-2.6
killall hostapd
killall zte_volte
killall wifi_manager
killall hostapd 
killall udhcpd
killall sd_hotplug

killall syslogd
rm -rf /var/log

#EC 616000558980
killall zte_mifi
killall zte_cpe
echo 7 >/proc/sys/vm/drop_caches

#可能还要删除某些占内存的线程

