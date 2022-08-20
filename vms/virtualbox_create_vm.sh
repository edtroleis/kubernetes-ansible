#!/bin/bash
MACHINENAME=$1

DISK_FILENAME="ubuntu-22.04-64bit.7z"
DISK_VDI=${MACHINENAME}.vdi
BASE_FOLDER="E:\VirtualBoxVMs"

# https://doc-0g-7g-docs.googleusercontent.com/docs/securesc/04h2clh4ceohtt2c4o7bv1eoepn7dlfj/5kllp5332c6ag075csdhl14h1r77mkel/1660537350000/03854773277332866080/03035033603652941582/1407kJDebHgxqAN0du0_jhH6kZDBXW5q6?e=download&ax=AI9vYm4ZqmZR5tynDNwpZJ8g_EhoCvbqV8aJdSILrwuDKDv5e0eGiUMY6G5JDzpmx6m3QQo4XgFD0bomkygiaJI46Okum1BoqS-LFJZlYc6NbnJIPSRXbfY5-d5GcQeT9NHOSYV_C-lfVVOTDA2V3Gr-I6X2dW7M1opGi7VN8anGzw9yXIKp4NhkUk2aGjn3k79QBYRezr69EwgRcfpYlVJqDjQQpWdHkn1UahfroVh_lwYbU_ufwbDHaEurWv0z6r1jM2Znc4OHGSLIS2DtjH53HGP4dlmAqpRQc7Q4d-U_1wSCHsNKqb8cnXFU9OdfkxMs4EEg0VfmcmlKIAQ1ZgqD8XUS5A7gtNDmA-ykOZP5xbr1MFx1XqdCxYElGyPB1dQy27Ma6avmNQCUALd__IW0PrQsFIOZ3txZX1HcXWch_cBiOmmRE0pYn7vyeFrruJk7hbjK7llz6sZFc6a1gXCD4BuBbPOmpmCMFOFEokQD2zmDTcydknjr9LtQncbKKfeQq1t7KCq9Rk64oUIHQB0ydeINHx7F8UB9x3aUr7WQxLgQ7aTrqRXmvA05uMS_BzIWBXbHRK5mEmk4gXZXHF2U93gqiEcatmO6Q8jaVOcM6OsQusQO_6hgfW8zk4JHc7s-lk6o45KmdHrJ7hL87r9LUEcCQz3RjjC_6mEknSaaGZKjG5BCfetJ_gdgm2smMp2O-MmE5tBqPnlC3Gpq&uuid=27165e3f-3393-42ba-86a4-8eb8f2bbe71e&authuser=0

# Download disk vdi
# if [ ! -f ./$DISK_FILENAME ]; then
#     wget https://ufpr.dl.sourceforge.net/project/osboxes/v/vb/55-U-u/22.04/64bit.7z -O $DISK_FILENAME | 7z x $DISK_FILENAME
# fi

#Create VM
VBoxManage.exe createvm --name $MACHINENAME --ostype "Ubuntu_64" --register --basefolder $BASE_FOLDER

# Create disk and connect
# Chage uuid disk to create vms using images from osboxes
if [ ! -f /mnt/e/VirtualBoxVMs/$MACHINENAME/$DISK_VDI ]; then
  # VBoxManage.exe internalcommands sethduuid ./64bit/'Ubuntu 22.04 (64bit).vdi'
  cp /mnt/e/virtualbox_baseimage/ubuntu-22.04-64bit.vdi /mnt/e/VirtualBoxVMs/$MACHINENAME/$DISK_VDI
  VBoxManage.exe internalcommands sethduuid 'E:/virtualbox_baseimage/ubuntu-22.04-64bit.vdi'
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
VBoxManage.exe modifyvm $MACHINENAME --nic1 natnetwork \
                                    --nat-network1 NatNetwork \
                                    --nic2 hostonly \
                                    --hostonlyadapter2 'VirtualBox Host-Only Ethernet Adapter'

# Shared folder
VBoxManage.exe sharedfolder add $MACHINENAME --name='shared' --hostpath='E:\shared' --automount --auto-mount-point='/mnt/shared'

#Start the VM
VBoxManage.exe startvm $MACHINENAME
