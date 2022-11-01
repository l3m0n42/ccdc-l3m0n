#!/bin/bash
if [ "$EUID" -ne 0 ]; then
	echo 'script requires root privileges'
	exit 1
fi
ip addr show
read -p 'desired interface for container to listen on: ' interface
manager_detection(){	
	if [ $(command -v apt) ]; then
		apt remove docker docker-engine docker.io containerd runc
		apt install ca-certificates curl gnupg lsb-release -y
		mkdir -p /etc/apt/keyrings
		curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
		echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
		chmod a+r /etc/apt/keyrings/docker.gpg
		apt update
		apt install docker.io docker-ce docker-ce-cli containerd.io docker-compose-plugin -y
		systemctl start docker
	elif [ $(command -v yum) ]; then
		remove docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-engine
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
$(echo 'Installing Snort container for you pumpkin <3')]];

docker pull plinton/docker-snort:latest
docker run -it --rm --net=host linton/docker-snort /bin/bash
docker exec plinton:snort "snort -i $interface -c /etc/snort/etc/snort.conf -A console"

}
manager_detection
container_install
