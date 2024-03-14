#!/bin/sh
path_sh=`nv get path_sh`
. $path_sh/global.sh
echo "Info: config-dns.sh $1 $2 start" >> $test_log
fname=$path_conf"/etc/resolv.conf"
fbak=$path_conf"/etc/resolv_conf.bak"

touch $fname

sed -e '/nameserver/d' $fname > $fbak

if [ "x$1" != "x" ]; then
  echo "nameserver $1" > $fname
else # empty dns
  rm -f $fname
fi
if [ "x$2" != "x" ]; then
  echo "nameserver $2" >> $fname
fi

cat $fbak >> $fname
rm -f $fbak

