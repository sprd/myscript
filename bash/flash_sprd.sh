#!/bin/bash

###############################################################
# Author: Kelvin Cheung
# Date: 2013/6/25
# Function: to upgrade firmware of Spreadtrum phone.
###############################################################

IMGS_DIR=`pwd`
DEPTH=1
UBOOT_IMG=u-boot-256M.bin
KERNEL_IMG=boot.img
RECOVERY_IMG=recovery.img
SYSTEM_IMG=system.img
USERDATA_IMG=userdata.img

FLASH_ALL=0
FLASH_BOOT=0
FLASH_KERNEL=0
FLASH_RECOVERY=0
FLASH_SYSTEM=0
FLASH_USERDATA=0

usage()
{
	echo "Usage: `basename $0` [-abkrsu] [-d] path"
	echo "−a: flash all images."
	echo "−b: flash bootloader."
	echo "−k: flash kernel."
	echo "−r: flash recovery"
	echo "−s: flash system."
	echo "−u: flash userdata"
	echo "−d: specify the path which contains images."
	echo "−h: display help."
	echo ""
	exit 0
}

flash_partition()
{
	if [[ "${FLASH_ALL}" -eq 1 || "$1" -eq 1 ]]; then
		IMG_PATH=`find ${IMGS_DIR} -maxdepth ${DEPTH} -type f -iname $3`
		[ -n "${IMG_PATH}" ] && (echo "---- Programming $3 ... "; fastboot flash $2 ${IMG_PATH}; echo)
	fi
}

NO_ARGS=0
if [ $# -eq $NO_ARGS ]; then
	FLASH_KERNEL=1
	FLASH_RECOVERY=1
	FLASH_SYSTEM=1
fi

while getopts ":habkrsud:" opt; do
	case $opt in
	a ) FLASH_ALL=1;;
	b ) FLASH_BOOT=1;;
	k ) FLASH_KERNEL=1;;
	r ) FLASH_RECOVERY=1;;
	s ) FLASH_SYSTEM=1;;
	u ) FLASH_USERDATA=1;;
	d ) IMGS_DIR=$OPTARG;FLASH_KERNEL=1;FLASH_RECOVERY=1;FLASH_SYSTEM=1;;
	h ) usage;return;;
	* ) echo "Unimplemented option chosen.";; # DEFAULT
	esac
done
shift $(($OPTIND - 1))

if [ -d ${IMGS_DIR} ]; then
	pushd ${IMGS_DIR}
	echo
else
	echo "No such directory"
	exit
fi

DEVICE=`fastboot devices`
[ -z "${DEVICE}" ] && (echo "No device"; exit)
echo ${DEVICE}; echo

flash_partition ${FLASH_BOOT} 2ndbl ${UBOOT_IMG}
flash_partition ${FLASH_KERNEL} boot ${KERNEL_IMG}
flash_partition ${FLASH_RECOVERY} recovery ${RECOVERY_IMG}
flash_partition ${FLASH_SYSTEM} system ${SYSTEM_IMG}
flash_partition ${FLASH_USERDATA} userdata ${USERDATA_IMG}

fastboot reboot

popd
