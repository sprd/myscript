#!/bin/bash

DIR=~/ubuntu_setup

proxy_setup(){
	wget http://10.6.2.82/tools/python-support_1.0.14ubuntu2_all.deb
	wget http://10.6.2.82/tools/ntlmaps_0.9.9.0.1-11.2ubuntu1_all.deb

	dpkg -i python-support_1.0.14ubuntu2_all.deb
	dpkg -i ntlmaps_0.9.9.0.1-11.2ubuntu1_all.deb

	echo "export http_proxy=http://127.0.0.1:5865" >> ~/.bashrc
	echo "export https_proxy=http://127.0.0.1:5865" >> ~/.bashrc

	export http_proxy=http://127.0.0.1:5865
	export https_proxy=http://127.0.0.1:5865
}

apt_setup(){
	mv /etc/apt/sources.list /etc/apt/sources.list.bak
	wget http://10.6.2.82/tools/sources.list.cn
	cp sources.list.cn /etc/apt/sources.list

	apt-get update
	apt-get upgrade
}

jdk_setup(){
	mkdir /usr/lib/jvm
	aria2c http://10.6.2.82/tools/jdk-6u43-linux-x64.bin
	cp jdk-6u43-linux-x64.bin /usr/lib/jvm/
	cd /usr/lib/jvm
	chmod +x jdk-6u43-linux-x64.bin
	./jdk-6u43-linux-x64.bin

	update-alternatives --install /usr/bin/java java /usr/lib/jvm/jdk1.6.0_43/bin/java 300
	update-alternatives --install /usr/bin/javac javac /usr/lib/jvm/jdk1.6.0_43/bin/javac 300
	update-alternatives --install /usr/bin/jar jar /usr/lib/jvm/jdk1.6.0_43/bin/jar 300
	update-alternatives --config java
	update-alternatives --config javac
	update-alternatives --config jar

	echo "export PATH=$PATH:/usr/lib/jvm/jdk1.6.0_43/bin" >> ~/.bashrc
}

#Install tools
tools_setup(){
	apt-get install build-essential
	apt-get install openssh-client openssh-server vim curl \
		git gnupg flex bison gperf \
		zip curl libc6-dev libncurses5-dev:i386 x11proto-core-dev \
		libx11-dev:i386 libreadline6-dev:i386 libgl1-mesa-glx:i386 \
		libgl1-mesa-dev g++-multilib mingw32 tofrodos \
		python-markdown libxml2-utils xsltproc zlib1g-dev:i386

	ln -s /usr/lib/i386-linux-gnu/mesa/libGL.so.1 /usr/lib/i386-linux-gnu/libGL.so
}

mkdir $DIR
cd $DIR 

proxy_setup
apt_setup

apt-get install aria2

jdk_setup
tools_setup

