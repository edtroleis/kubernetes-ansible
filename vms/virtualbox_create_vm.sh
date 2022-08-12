#!/bin/bash
MACHINENAME=$1

DISK_FILENAME="ubuntu-22.04-64bit.7z"
DISK_VDI=${MACHINENAME}.vdi
BASE_FOLDER="E:\VirtualBoxVMs"

# Download disk vdi
if [ ! -f ./$DISK_FILENAME ]; then
    wget https://ufpr.dl.sourceforge.net/project/osboxes/v/vb/55-U-u/22.04/64bit.7z -O $DISK_FILENAME | 7z x $DISK_FILENAME
fi

#Create VM
VBoxManage.exe createvm --name $MACHINENAME --ostype "Ubuntu_64" --register --basefolder $BASE_FOLDER #`pwd`

# Create disk and connect
# Chage uuid disk to create vms using images from osboxes
if [ ! -f /mnt/e/VirtualBoxVMs/$MACHINENAME/$DISK_VDI ]; then
  VBoxManage.exe internalcommands sethduuid ./64bit/'Ubuntu 22.04 (64bit).vdi'
  cp ./64bit/'Ubuntu 22.04 (64bit).vdi' /mnt/e/VirtualBoxVMs/$MACHINENAME/$DISK_VDI
fi

# Connect disk
VBoxManage.exe storagectl $MACHINENAME --name "SATA Controller" --add sata --controller IntelAhci
VBoxManage.exe storageattach $MACHINENAME --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "E:\VirtualBoxVMs\\$MACHINENAME\\$DISK_VDI"

# Geral
VBoxManage.exe modifyvm $MACHINENAME --draganddrop bidirectional \
                                    --clipboard-mode bidirectional

# System
VBoxManage.exe modifyvm $MACHINENAME --ioapic on \
                                    --memory 2048 \
                                    --cpus 2 \
                                    --boot1 disk --boot2 none --boot3 none \
                                    --rtcuseutc on \
                                    --pae off

# Monitor
VBoxManage.exe modifyvm $MACHINENAME --vram 64 \
                                    --graphicscontroller vmsvga \
                                    --vrdevideochannelquality 125

# Audio
VBoxManage.exe modifyvm $MACHINENAME --audio none

# Network
VBoxManage.exe modifyvm $MACHINENAME --nic1 NatNetwork

# Shared folder
VBoxManage.exe sharedfolder add $MACHINENAME --name='shared' --hostpath='E:\shared' --automount --auto-mount-point='/mnt/shared'

#Start the VM
VBoxManage.exe startvm $MACHINENAME
