#!/bin/bash
MACHINENAME=$1

GDRIVE_FILEID="1407kJDebHgxqAN0du0_jhH6kZDBXW5q6"
GDRIVE_FILENAME="ubuntu-22.04-64bit.tar.gz"

BASE_IMAGE_DIR="/mnt/e/virtualbox_baseimage"
BASE_IMAGE_NAME="ubuntu-22.04-64bit.vdi"

VM_BASE_DIR_LNX="/mnt/e/VirtualBoxVMs"
DISK_VDI=${MACHINENAME}.vdi
VM_BASE_DIR_WIN="E:\VirtualBoxVMs"

if [ ! -d $BASE_IMAGE_DIR ] 
then
    echo "$BASE_IMAGE_DIR does not exist, creating..." 
    mkdir -p $BASE_IMAGE_DIR
fi

# Download disk from Google Drive
if [ ! -f $BASE_IMAGE_DIR/$BASE_IMAGE_NAME ]; then
  html=`curl -c ./cookie -s -L "https://drive.google.com/uc?export=download&id=${GDRIVE_FILEID}"`
  curl -Lb ./cookie "https://drive.google.com/uc?export=download&`echo ${html}|grep -Po '(confirm=[a-zA-Z0-9\-_]+)'`&id=${GDRIVE_FILEID}" -o $BASE_IMAGE_DIR/${GDRIVE_FILENAME}
  tar -zxvf $BASE_IMAGE_DIR/${GDRIVE_FILENAME} -C $BASE_IMAGE_DIR
fi

# Create VM
VBoxManage.exe createvm --name $MACHINENAME --ostype "Ubuntu_64" --register --basefolder $VM_BASE_DIR_WIN

# Create disk and connect
# Chage uuid disk to create vms using images from osboxes
if [ ! -f $VM_BASE_DIR_LNX/$vm/$DISK_VDI ]; then
  cp $BASE_IMAGE_DIR/$BASE_IMAGE_NAME $VM_BASE_DIR_LNX/$MACHINENAME/$DISK_VDI
  VBoxManage.exe internalcommands sethduuid "$VM_BASE_DIR_WIN\\$MACHINENAME\\$DISK_VDI"
fi

# Connect disk
VBoxManage.exe storagectl $MACHINENAME --name "SATA Controller" --add sata --controller IntelAhci
VBoxManage.exe storageattach $MACHINENAME --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "$VM_BASE_DIR_WIN\\$MACHINENAME\\$DISK_VDI"

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
VBoxManage.exe modifyvm $MACHINENAME --nic1 natnetwork \
                                    --nat-network1 NatNetwork \
                                    --nic2 hostonly \
                                    --hostonlyadapter2 'VirtualBox Host-Only Ethernet Adapter'

# Shared folder
VBoxManage.exe sharedfolder add $MACHINENAME --name='shared' --hostpath='E:\shared' --automount --auto-mount-point='/mnt/shared'

#Start the VM
VBoxManage.exe startvm $MACHINENAME
