#!/bin/bash

GDRIVE_FILEID="1407kJDebHgxqAN0du0_jhH6kZDBXW5q6"
GDRIVE_FILENAME="ubuntu-22.04-64bit.tar.gz"

BASE_IMAGE_DIR="/mnt/e/virtualbox_baseimage"
BASE_IMAGE_NAME="ubuntu-22.04-64bit.vdi"

VM_BASE_DIR_LNX="/mnt/e/VirtualBoxVMs"

VM_BASE_DIR_WIN="E:\VirtualBoxVMs"

VMS=('k8s-master' 'k8s-worker1' 'k8s-worker2')

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

for vm in "${VMS[@]}"
do
  printf "### Creating VM $vm...\n"
  DISK_VDI="${vm}.vdi"

  #Create VM
  VBoxManage.exe createvm --name $vm --ostype "Ubuntu_64" --register --basefolder $VM_BASE_DIR_WIN

  # Create disk and connect
  # Chage uuid disk to create vms using images from osboxes
  if [ ! -f $VM_BASE_DIR_LNX/$vm/$DISK_VDI ]; then
    cp $BASE_IMAGE_DIR/$BASE_IMAGE_NAME $VM_BASE_DIR_LNX/$vm/$DISK_VDI
    VBoxManage.exe internalcommands sethduuid "$VM_BASE_DIR_WIN\\$vm\\$DISK_VDI"
  fi

  # Connect disk
  VBoxManage.exe storagectl $vm --name "SATA Controller" --add sata --controller IntelAhci
  VBoxManage.exe storageattach $vm --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "$VM_BASE_DIR_WIN\\$vm\\$DISK_VDI"

  # Geral
  VBoxManage.exe modifyvm $vm --draganddrop bidirectional \
                                      --clipboard-mode bidirectional

  # System
  VBoxManage.exe modifyvm $vm --ioapic on \
                                      --memory 2048 \
                                      --cpus 2 \
                                      --boot1 disk --boot2 none --boot3 none \
                                      --rtcuseutc on \
                                      --pae off

  # Monitor
  VBoxManage.exe modifyvm $vm --vram 64 \
                                      --graphicscontroller vmsvga \
                                      --vrdevideochannelquality 125

  # Audio
  VBoxManage.exe modifyvm $vm --audio none

  # Network
  VBoxManage.exe modifyvm $vm --nic1 natnetwork \
                                      --nat-network1 NatNetwork \
                                      --nic2 hostonly \
                                      --hostonlyadapter2 'VirtualBox Host-Only Ethernet Adapter'

  # Shared folder
  VBoxManage.exe sharedfolder add $vm --name='shared' --hostpath='E:\shared' --automount --auto-mount-point='/mnt/shared'

  #Start the VM
  VBoxManage.exe startvm $vm

  printf "### VM $vm created succesfully!\n\n"
  sleep 15
done

# Set entries on /etc/hosts
printf "### Adding hostname/IP on /etc/hosts\n"
sleep 15
printf "\n# Ansible hosts\n" >> /etc/hosts

for vm in "${VMS[@]}"
do
  VM_IP=$(VBoxManage.exe guestproperty enumerate "$vm" | grep "/VirtualBox/GuestInfo/Net/1/V4/IP" | grep -o -w -P -e '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}')
  printf "$VM_IP\t$vm\n" >> /etc/hosts
done
printf "### Hostname/IP added on /etc/hosts\n"