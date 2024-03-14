#!/bin/sh


customer_type=$(nv get customer_type)
if [ x"${customer_type}" == x"guodian" ];then
    nv set fota_updateMode=0
    nv set pwron_auto_check=0
    nv set mmi_showmode=led
    nv set mmi_task_tab=net_task+ctrl_task
    nv set mmi_led_mode=sleep_mode
    zte_mmi &
    nv set self_adaption_port=/dev/ttyS0
elif [ x"${customer_type}" == x"nandian" ]; then
    nv set fota_updateMode=0
    nv set pwron_auto_check=0
    nv set mmi_showmode=led
    nv set mmi_task_tab=net_task+ctrl_task+key_task
    nv set mmi_led_mode=sleep_mode
    zte_mmi &
    nv set self_adaption_port=/dev/ttyS0
fi
