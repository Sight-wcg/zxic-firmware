#!/bin/sh

RECVFS_MTD_NUM=`cat /proc/mtd | grep "$2\"" | awk '{print $1}'| cut -b 4- |sed 's/://g'`
ubiattach /dev/ubi_ctrl -m ${RECVFS_MTD_NUM}
echo "attach $2  $1"

if [ $? != 0 ];then
	echo "fail to attach $2"	
	exit 1
fi

UBIDEV_NUM=`ls /sys/devices/virtual/ubi|wc -l`
MYTMP=0

if [ ! -e $1 ]; then
	mkdir -p $1
fi

while :
do
	if [ -e /sys/devices/virtual/ubi/ubi${MYTMP} ]; then
		TMPDEV=`cat /sys/devices/virtual/ubi/ubi${MYTMP}/mtd_num`
		if [ $TMPDEV -eq ${RECVFS_MTD_NUM} ]; then
			mount -t ubifs  -o rw,sync,noatime ubi${MYTMP}_0 $1
			exit 0
		fi
	else
		if [ ${MYTMP} -ge ${UBIDEV_NUM} ]; then
			exit 1
		fi
	fi
	MYTMP=`expr $MYTMP + 1`
done


