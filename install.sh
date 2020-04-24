#!/usr/bin/env bash

# Recommend installing on fresh Ubuntu 20.04

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

if [ $# -eq 0 ]
  then
    echo "No arguments supplied"
    echo "./install.sh <new username>"
    exit 0
fi

# assign vars
LINUX_VERSION=$(lsb_release -c | awk {'print $2'})
NEW_USER=$1

echo "Starting..."
mkdir -p /storage # placeholder for some apps. Admin should reconfigure if necessary.
mkdir -p /usr/src # where we'll download some code for install

echo "Disable firewall... (configure and enable after setting up your core services)"
ufw disable

echo "Creating user $NEW_USER..."
useradd -s /bin/bash -d /home/$NEW_USER/ -m -G sudo $NEW_USER
NEW_USER_UID=$(id -u $NEW_USER)

# Enable backports / latest software releases in unstable channel
echo "deb http://archive.ubuntu.com/ubuntu $LINUX_VERSION-backports main restricted universe multiverse" >> /etc/apt/sources.list

# prefer unstable over stable software (just means latest versions will be used)
cat << EOF >> /etc/apt/preferences
Pin: release a=$LINUX_VERSION-backports
Pin-Priority: 100
EOF

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
apt-get install -y htop iotop iftop net-tools nano tmux screen vim

echo "Install Docker"
apt-get install -y docker.io
systemctl start docker
systemctl enable docker

echo "Installing S.M.A.R.T. Tools..."
apt-get install -y smartmontools

echo "Install ZFS utilities"
apt-get install -y zfsutils-linux

echo "Installing KVM and QEMU..."
apt-get install -y \
libvirt-bin libvirt-clients libvirt-daemon-system libvirt-dbus \
virtinst virtinst bridge-utils \
qemu-block-extra qemu-kvm qemu-system

kvm-ok
sleep 5

#echo "Configure KVM..."
#modprobe kvm_intel nested=1
#echo "options kvm_intel nested=1" >> /etc/modprobe.d/kvm.conf
#echo "options kvm_amd nested=1" >> /etc/modprobe.d/kvm.conf

# ?
#virsh pool-define-as default dir --target /var/lib/libvirt/images/
#virsh pool-start default
#virsh pool-autostart default

echo "Install Cockpit..."
add-apt-repository ppa:cockpit-project/cockpit
apt-get get update
apt-get -y install cockpit cockpit-bridge cockpit-system cockpit-ws cockpit-dashboard cockpit-networkmanager cockpit-packagekit cockpit-storaged cockpit-doc cockpit-docker cockpit-machines cockpit-pcp
systemctl start cockpit
systemctl enable cockpit

echo "Installing and configuring Portainer..."
docker volume create portainer_data
docker run -d \
    --name=portainer \
    -e PUID=$NEW_USER_UID \
    -e PGID=$NEW_USER_UID \
    -e TZ=UTC \
    -p 8000:8000 \
    -p 9000:9000 \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v portainer_data:/data \
    --restart always \
    portainer/portainer

echo "Installing and configuring Heimdall...."
docker run -d \
    --name=heimdall \
    -e PUID=$NEW_USER_UID \
    -e PGID=$NEW_USER_UID \
    -e TZ=UTC \
    -p 443:443 \
    -v /etc/heimdall/config:/config \
    --restart always \
    linuxserver/heimdall

echo "Install Deluge..."
mkdir -p $HOME/Downloads
docker run -d \
    --name deluge \
    -e PUID=$NEW_USER_UID \
    -e PGID=$NEW_USER_UID \
    -e TZ=UTC \
    -p 8112:8112 \
    -v /etc/deluge/config:/data \
    -v $HOME/Downloads:/torrent \
    --restart always \
    lacsap/deluge-web

echo "Installing Handbrake..."
docker run -d \
    --name handbrake \
    -e PUID=$NEW_USER_UID \
    -e PGID=$NEW_USER_UID \
    -e TZ=UTC \
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
echo "Portainer: http://localhost:9000"

printf "\nCOMPLETE! Rebooting in 15 seconds....\n\n"

sleep 15
reboot
