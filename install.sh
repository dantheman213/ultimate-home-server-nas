#!/usr/bin/env bash

# Recommend installing on fresh Ubuntu 20.04

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

echo "Starting..."
mkdir -p /storage # placeholder for some apps. Admin should reconfigure if necessary.

echo "Disable firewall... (configure and enable after setting up your core services)"
ufw disable

echo "Updating sources"
add-apt-repository universe
apt-get update

echo "Installing any available package upgrades"
apt-get upgrade -y

echo "Setting timezone to UTC and syncing time with Google time server...."
apt-get install -y ntp
timedatectl set-timezone UTC
ntpdate -u time.google.com

echo "Install misc tools"
apt-get install -y htop iotop iftop nano tmux screen vim

echo "Install Cockpit..."
add-apt-repository ppa:cockpit-project/cockpit
apt-get get update
apt-get -y install cockpit cockpit-machines cockpit-docker cockpit-packagekit cockpit-networkmanager cockpit-storaged cockpit-system
systemctl start cockpit
systemctl enable cockpit

echo "Install Docker"
apt-get install -y docker.io
systemctl start docker
systemctl enable docker

echo "Installing S.M.A.R.T. Tools..."
apt-get install -y smartmontools

echo "Install ZFS utilities"
apt-get install -y zfsutils-linux

echo "Installing and configuring Portainer..."
docker volume create portainer_data
docker run -d -p 8000:8000 -p 9000:9000 --name=portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer

echo "Installing and configuring Heimdall...."
docker run \
  -d \
  --name=heimdall \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=UTC \
  -p 443:443 \
  -v /etc/heimdall/config:/config \
  --restart always \
  linuxserver/heimdall

echo "Installing KVM and QEMU..."
apt-get install -y qemu qemu-kvm libvirt-bin libvirt-clients libvirt-daemon-system bridge-utils virt-manager
kvm-ok
sleep 5

echo "Installing Kimchi, Wok, and dependencies..."
docker run -d --restart=always --net=host --name kimchi \
  -v /etc/passwd:/etc/passwd:ro \
  -v /etc/group:/etc/group:ro \
  -v /etc/shadow:/etc/shadow:ro \
  -v /var/run/libvirt/libvirt-sock:/var/run/libvirt/libvirt-sock \
  -v /var/lib/libvirt:/var/lib/libvirt \
  -v /etc/libvirt:/etc/libvirt \
  -v /storage:/storage \
  -p 8001:8001 \
  --privileged
  dantheman213/kimchi:latest

echo "Install Deluge..."
mkdir -p $HOME/Downloads
docker run -d --name deluge -p 8112:8112 -v /etc/deluge/config:/data -v $HOME/Downloads:/torrent --restart always lacsap/deluge-web

echo "Installing Handbrake..."
docker run -d \
    --name handbrake \
    -p 5800:5800 \
    -v /docker/appdata/handbrake:/config:rw \
    -v $HOME:/storage:ro \
    -v $HOME/workspace/HandBrake/watch:/watch:rw \
    -v $HOME/workspace/HandBrake/output:/output:rw \
    --restart always \
    jlesage/handbrake

printf "\n\nSERVICES AVAILABLE:\n"
echo "*****"
echo "PRIMARY DASHBOARD [Heimdall]: https://localhost"
echo "*****"
printf "\nIndividual Service Dashboards:\n"
echo "Cockpit: https://localhost:9090"
echo "Deluge: http://localhost:8112"
echo "Handbrake: http://localhost:5800"
echo "Kimchi: https://localhost:8001"
echo "Portainer: http://localhost:9000"

printf "\nCOMPLETE! Rebooting in 15 seconds....\n\n"

sleep 15
reboot
