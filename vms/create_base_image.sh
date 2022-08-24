#!/bin/bash

# This custom image is uploaded on Drive.
# When run scripts virtualbox_create_vms_k8s.sh or virtualbox_create_vm.sh kube-master this custom image will be downloaded

apt update

# Install guest additions requirements
apt install -y build-essential linux-headers-$(uname -r)

# Install packages
apt install -y openssh-server net-tools vim

# Solve issue "Virtualbox shared folder permissions - permission denied"
sudo adduser $USER vboxsf  

# Install VBoxGuestAdditions
VBOX_VERSION="6.1.36"
VBOX_GUEST_ADDITIONS="VBoxGuestAdditions_${VBOX_VERSION}.iso"

# Download VBoxGuestAdditions
if [ ! -f ./$VBOX_GUEST_ADDITIONS ]; then
    wget https://download.virtualbox.org/virtualbox/${VBOX_VERSION}/VBoxGuestAdditions_${VBOX_VERSION}.iso -O $VBOX_GUEST_ADDITIONS
fi

mount $VBOX_GUEST_ADDITIONS /media
cd /media
./ VBoxLinuxAdditions.run
cd ~
sudo umount /media
rm $VBOX_GUEST_ADDITIONS
reboot
