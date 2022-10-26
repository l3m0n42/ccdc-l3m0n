#!/bin/bash
if [ "$EUID" -ne 0 ]; then
	echo 'script requires root privileges'
	exit 1
fi

if [ $(command -v snort) ]; then
	echo 'snort already installed'
	exit 1
fi
manager_detection(){

	if [ $(command -v apt) ]; then
		apt install build-essential bison flex libpcap-dev libpcre3 libpcre3-dev libdumbnet-dev zlib1g-dev libnghttp2-dev openssl libdnet apache2 libapache2-mod-php libphp-adodb php-pear libwww-perl php-gd -y

		cd /tmp
		wget https://www.snort.org/downloads/snort/daq-2.0.7.tar.gz
		wget https://www.snort.org/downloads/snort/snort-2.9.20.tar.gz
		tar xvzf daq-2.0.7.tar.gz
		cd daq-2.0.7
		./configure && make && sudo make install 
		cd ..
		tar xvzf snort-2.9.20.tar.gz
		cd snort-2.9.20
		./configure --enable-sourcefire && make && sudo make install

	elif [ $(command -v yum) ]; then
        	yum install https://www.snort.org/downloads/snort/

	elif [ $(command -v pacman) ]; then
		echo 'thats not good'
	elif [ $(command -v apk) ]; then    
		echo 'stop'
	fi
}
manager_detection
