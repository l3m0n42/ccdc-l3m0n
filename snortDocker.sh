#!/bin/bash
set -eu -o pipefail

if [ "$EUID" -ne 0 ]; then
	echo 'script requires root privileges'
	exit 1
fi

manager_detection(){	
	if [ $(command -v apt) ]; then
		apt update
		apt install docker.io -y
		systemctl start docker
	elif [ $(command -v yum) ]; then
		remove docker \
                  	docker-client \
                  	docker-client-latest \
                  	docker-common \
                  	docker-latest \
                  	docker-latest-logrotate \
                  	docker-logrotate \
                  	docker-engine
		yum install -y yum-utils
		yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
		yum install docker-ce docker-ce-cli containerd.io docker-compose-plugin
		systemctl start docker
	
	elif [ $(command -v pacman) ]; then
		pacman -S gnome-terminal
		packman -S wget
		cd /tmp
		wget https://download.docker.com/linux/static/stable/aarch64/docker-20.10.9.tgz
		tar xzvf docker-20.10.9.tgz
		sudo cp docker/* /usr/bin/
		dockerd &
	elif [ $(command -v apk) ]; then
		apk add --update docker openrc
		read -p 'desired docker user: ' userselect
		addgroup $userselect docker
		service docker start
	fi
}
container_install(){
	if [[ "$(docker image inspect linton:docker-snort 2> /dev/null)" == "" ]]; then
		echo 'Snort container already installed'
		read -p 'desired interface for docker: ' interface
		docker run -it --rm --net=host linton/docker-snort /bin/bash
		snort -i $interface -c /etc/snort/etc/snort.conf -A console	
	
	else [[$(echo 'Installing Snort container <3')]]; then
		docker pull linton/docker-snort
                read -p 'desired interface for docker: ' interface
                docker run -it --rm --net=host linton/docker-snort /bin/bash
                snort -i $interface -c /etc/snort/etc/snort.conf -A console


	fi

}
manager_detection
container_install
