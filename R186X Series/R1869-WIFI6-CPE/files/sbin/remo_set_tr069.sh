#!/bin/sh

CFG_PATH="/cache/cwmp.conf"
TR069_ENABLE_KEY="enable"
ACS_URL_KEY="acs_url"
ACS_AUTH_KEY="acs_auth"
ACS_USR_KEY="acs_username"
ACS_PASS_KEY="acs_password"
CPE_AUTH_KEY="cpe_auth"
CPE_USR_KEY="cpe_username"
CPE_PASS_KEY="cpe_password"
PERIODIC_ENABLE_KEY="enable"
PERIODIC_INTERVAL_KEY="interval"
STUN_ENBALE="stun_enable"
STUN_S_URL="stun_serveraddress"
STUN_S_PORT="stun_serverport"
STUN_USER="stun_username"
STUN_PASSWD="stun_password"

string_to_regex(){
    str=$1
    regex_str=""
    len=`echo $str | wc -c`
    for i in $(seq 1 ${len})
    do
        c=`expr substr "$str" ${i-1} 1`
        if [ "$c" = "." -o "$c" = "^" -o "$c" = "$" -o "$c" = "[" -o "$c" = "]" -o "$c" = "*" -o "$c" = '\' -o "$c" = '/' ]; then
           regex_str=$regex_str"\\"
        fi
        regex_str=$regex_str$c
    done
    echo $regex_str
}

tr069_enable=`nv get tr069_service`
acs_url=`nv get tr069_acs_url`
acs_auth=`nv get tr069_acs_auth`
acs_auth_usr=`nv get tr069_acs_auth_usr`
acs_auth_passwd=`nv get tr069_acs_auth_passwd`
cpe_auth=`nv get tr069_cpe_auth`
cpe_auth_usr=`nv get tr069_cpe_auth_usr`
cpe_auth_passwd=`nv get tr069_cpe_auth_passwd`
periodic_info=`nv get tr069_periodic_info`
periodic_info_interval=`nv get tr069_periodic_info_interval`
stun_enable=`nv get tr069_stun_switch`
stun_serveraddress=`nv get tr069_stun_url`
stun_serverport=`nv get tr069_stun_port`
stun_username=`nv get tr069_stun_usrname`
stun_password=`nv get tr069_stun_passwd`


if [ "-$tr069_enable" = "-enable" ]; then
    sed -i ":a;N;\$!ba;s/$TR069_ENABLE_KEY=[0,1]*/$TR069_ENABLE_KEY=1/1" $CFG_PATH
else
    sed -i ":a;N;\$!ba;s/$TR069_ENABLE_KEY=[0,1]*/$TR069_ENABLE_KEY=0/1" $CFG_PATH
fi

url=`string_to_regex $acs_url`
sed -i "s/^$ACS_URL_KEY=.\+/$ACS_URL_KEY=$url/"   $CFG_PATH
if [ "-$acs_auth" == "-enable" ]; then
    sed -i "s/$ACS_AUTH_KEY=[0,1]*/$ACS_AUTH_KEY=1/"  $CFG_PATH
else

    sed -i "s/$ACS_AUTH_KEY=[0,1]*/$ACS_AUTH_KEY=0/"  $CFG_PATH
fi
usr=`string_to_regex $acs_auth_usr`
sed -i "s/^$ACS_USR_KEY=.\+/$ACS_USR_KEY=$usr/"   $CFG_PATH
passwd=`string_to_regex $acs_auth_passwd`
sed -i "s/^$ACS_PASS_KEY=.\+/$ACS_PASS_KEY=$passwd/"   $CFG_PATH
if [ "-$cpe_auth" == "-enable" ]; then
    sed -i "s/$CPE_AUTH_KEY=[0,1]*/$CPE_AUTH_KEY=1/"  $CFG_PATH
else
    sed -i "s/$CPE_AUTH_KEY=[0,1]*/$CPE_AUTH_KEY=0/"  $CFG_PATH
fi
usr=`string_to_regex $cpe_auth_usr`
sed -i "s/^$CPE_USR_KEY=.\+/$CPE_USR_KEY=$usr/"   $CFG_PATH
passwd=`string_to_regex $cpe_auth_passwd`
sed -i "s/^$CPE_PASS_KEY=.\+/$CPE_PASS_KEY=$passwd/"   $CFG_PATH
if [ "-$periodic_info" == "-enable" ]; then
    sed -i ":a;N;\$!ba;s/$PERIODIC_ENABLE_KEY=[0,1]*/$PERIODIC_ENABLE_KEY=1/2" $CFG_PATH    # 处理第二个enable
else
    sed -i ":a;N;\$!ba;s/$PERIODIC_ENABLE_KEY=[0,1]*/$PERIODIC_ENABLE_KEY=0/2" $CFG_PATH 
fi
sed -i "s/^$PERIODIC_INTERVAL_KEY=.\+/$PERIODIC_INTERVAL_KEY=$periodic_info_interval/"   $CFG_PATH

if [ "-$stun_enable" == "-enable" ]; then
    sed -i "s/$STUN_ENBALE=[0,1]*/$STUN_ENBALE=1/"  $CFG_PATH
else

    sed -i "s/$STUN_ENBALE=[0,1]*/$STUN_ENBALE=0/"  $CFG_PATH
fi

url=`string_to_regex $stun_serveraddress`
sed -i "s/^$STUN_S_URL=.\+/$STUN_S_URL=$url/"   $CFG_PATH
usr=`string_to_regex $stun_username`
sed -i "s/^$STUN_USER=.\+/$STUN_USER=$usr/"   $CFG_PATH
passwd=`string_to_regex $stun_password`
sed -i "s/^$STUN_PASSWD=.\+/$STUN_PASSWD=$passwd/"   $CFG_PATH
sed -i "s/^$STUN_S_PORT=.\+/$STUN_S_PORT=$stun_serverport/"   $CFG_PATH
