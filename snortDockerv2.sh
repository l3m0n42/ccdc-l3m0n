#!/bin/bash
if [ "$EUID" -ne 0 ]; then
        echo 'script requires root privileges'
        exit 1
fi
interface=$(ip addr show | grep "[1-9]" | grep -v "link/ether" | grep -v "inet6" | grep "state UP" | awk {'print $2'} | sed 's/://')
manager_detection(){
        if [ $(command -v apt) ]; then
                apt update
                for i in docker.io docker-compose-plugin containerd.io; do apt install -y $i; done
                systemctl start docker
        elif [ $(command -v yum) ]; then
                yum install -y yum-utils device-mapper-persistent-data lvm2
		yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
                yum update
		yum install docker-ce containerd.io docker-compose-plugin
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
                sed -i '/community/s/^#//g' /etc/apk/repositories
		apk update 
		apk add docker openrc
		addgroup username docker
                rc-update add docker boot
                service docker start
		echo "waiting for docker service to start"
		sleep 5
        fi
}
container_install(){
	echo 'Installing Snort container for you, pumpkin <3'
	docker pull plinton/docker-snort:latest
	docker run -it --rm --net=host linton/docker-snort /bin/bash -c "snort -i $interface -c /etc/snort/etc/snort.conf -A console"
}
manager_detection
container_install
