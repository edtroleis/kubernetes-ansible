#!/bin/bash

apt update

# Install guest additions
apt install -y build-essential linux-headers-$(uname -r)

# Install network toos
apt install -y openssh-server net-tools vim

VBOX_VERSION="6.1.36"
VBOX_GUEST_ADDITIONS="VBoxGuestAdditions_${VBOX_VERSION}.iso"

# Download disk vdi
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