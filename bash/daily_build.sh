#!/bin/bash
. /etc/profile
. ~/.profile

BUILD_SYNC=0
REPO=/usr/bin/repo

# [trout | shark]
PLATFORM=trout

# specify source directory
SRC_DIR=`pwd`

# specify image directory
OUT_DIR=/tmp/

DAILY=`date +%Y-%m_%d-%H_%M`

params_init()
{
	OUT_DIR=$OUT_DIR/$DAILY
	LOG_FILE=$OUT_DIR/build.log
	ERR_FILE=$OUT_DIR/repo_sync.log
	VER_FILE=$OUT_DIR/Version.log
	VERSION=/home/`whoami`/bin/trout_version
	
	mkdir -p $OUT_DIR
}

trout_params_init()
{
	FM_DIR=$SRC_DIR/3rdparty/fm
	WIFI_DIR=$SRC_DIR/3rdparty/wifi

	FM_TGZ=$OUT_DIR/Trout_FM.$DAILY.tgz
	WIFI_TGZ=$OUT_DIR/Trout_WIFI.$DAILY.tgz
}

usage()
{
	echo ""
	echo "Usage: `basename $0` [-sh] [-d] src_dir [-o] out_dir [-p] platform"
	echo "	-s: sync with server before build."
	echo "	-d: specify the base directory."
	echo "		default: current directory."
	echo "	-o: specify the out directory."
	echo "	-p: specify platform: [trout | shark]"
	echo "	-h: display help."
	echo ""
	exit 0
}

#Sync the latest source code with server
repo_sync(){
	echo "Sync start at `date`" >> $LOG_FILE

	cd $SRC_DIR
	$REPO forall -c "git reset --hard && git checkout master" >> $LOG_FILE
	$REPO sync >> $LOG_FILE 2> $ERR_FILE

	echo "Sync end at `date`" >> $LOG_FILE
}

#Building
trout_build(){
	echo "Build start at `date`" >> $LOG_FILE

	cd $SRC_DIR
	rm -rf out
	./mk -o=2sim sp6820gb_trout2 genmd5 >> $LOG_FILE
	./mk -o=2sim:nocmccwifi sp6820gb_trout2 n >> $LOG_FILE

	echo "Build end at `date`" >> $LOG_FILE
}

shark_build(){
	echo "Build start at `date`" >> $LOG_FILE

	cd $SRC_DIR
	rm -rf out

	source build/envsetup.sh >> $LOG_FILE
	lunch 29 >> $LOG_FILE

	make >> $LOG_FILE

	echo "Build end at `date`" >> $LOG_FILE
}

trout_out_collect(){
	cd $SRC_DIR
	cp ./out/target/product/hsdroid/*.pac $OUT_DIR
	cp ./out/target/product/hsdroid/boot.img $OUT_DIR
	chmod 664 ./out/target/product/hsdroid/system.img
	cp ./out/target/product/hsdroid/system.img $OUT_DIR
	cp ./out/target/product/hsdroid/recovery.img $OUT_DIR
	$VERSION > $VER_FILE
	cp 3rdparty/fm/Trout_FM/special/driver/Changes.log $OUT_DIR/Changes_FM.log
	cp 3rdparty/wifi/Trout_WIFI/special/sdio_driver/Changes.log $OUT_DIR/Changes_SDIO.log
	cp 3rdparty/wifi/Trout_WIFI/special/mac/Changes.log $OUT_DIR/Changes_WIFI.log 

#	cd $BASE_DIR
#	tar zcf $TGZ $PROJECT --exclude=.repo --exclude=.git --exclude=$PROJECT/out

	cd $FM_DIR
	tar zcf $FM_TGZ Trout_FM --exclude=.repo --exclude=.git

	cd $WIFI_DIR
	tar zcf $WIFI_TGZ Trout_WIFI --exclude=.repo --exclude=.git
}

shark_out_collect(){
	cd $SRC_DIR
	
	touch $OUT_DIR/build_complete
}

NO_ARGS=0
if [ $# -eq $NO_ARGS ]; then
	#Default parameters
	echo
fi

while getopts ":shd:o:p:" opt; do
	case $opt in
	s ) BUILD_SYNC=1;;
	d ) SRC_DIR=$OPTARG;;
	o ) OUT_DIR=$OPTARG;;
	p ) PLATFORM=$OPTARG;;
	h ) usage;;
	* ) echo "Unimplemented option chosen.";; # DEFAULT
	esac
done

if [ ! -d ${SRC_DIR} ]; then
	echo "No such directory: "$SRC_DIR
	usage
	exit
fi

if [ ! -d ${OUT_DIR} ]; then
	echo "No such directory: "$OUT_DIR
	usage
	exit
fi

if [ $PLATFORM != shark -a $PLATFORM != trout ]; then
	echo "Invalid platform: "$PLATFORM
	usage
	exit
fi

params_init

if [ ${BUILD_SYNC} -eq 1 ]; then
	repo_sync
fi

if [ $PLATFORM = trout ]; then 
	echo "start to build Trout."
	trout_params_init
	trout_build
	trout_out_collect
fi

if [ $PLATFORM = "shark" ]; then
	echo "start to build Shark."

	shark_build
	shark_out_collect
fi
