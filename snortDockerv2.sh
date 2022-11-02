#!/bin/bash
if [ "$EUID" -ne 0 ]; then
        echo 'script requires root privileges'
        exit 1
fi
interface=$(ip -brief a | grep -v 127.0.0.1 | grep -E '[1-9]{,3}[.][1-9]{,3}[.][1-9]{,3}[.][1-9]' | awk {'print $1'})
manager_detection(){
        if [ $(command -v apt) ]; then
                apt update
                apt install docker.io docker-compose-plugin -y
	      	containerd.io -y
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
                apk update 
		apk add docker openrc
                read -p 'desired docker user: ' userselect
                addgroup $userselect docker
                service docker start
        fi
}
container_install(){
	$(echo 'Installing Snort container for you, pumpkin <3')]];
	docker pull plinton/docker-snort:latest
	docker run -it --rm --net=host linton/docker-snort /bin/bash -c "snort -i $interface -c /etc/snort/etc/snort.conf -A console"
}
manager_detection
container_install
