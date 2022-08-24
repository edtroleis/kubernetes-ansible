#!/bin/bash

VMS=('k8s-master' 'k8s-worker1' 'k8s-worker2')

printf "\n# Ansible hosts\n" >> /etc/hosts

for vm in "${VMS[@]}"
do
  VM_IP=$(VBoxManage.exe guestproperty enumerate "$vm" | grep "/VirtualBox/GuestInfo/Net/1/V4/IP" | grep -o -w -P -e '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}')
  printf "$VM_IP\t$vm\n" >> /etc/hosts
done

# for f in $(VBoxManage.exe list runningvms | awk -F\" '{print $2}'); do
#   VM_IP=$(VBoxManage.exe guestproperty enumerate "$f" | grep "/VirtualBox/GuestInfo/Net/1/V4/IP" | grep -o -w -P -e '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}')
#   printf "$VM_IP\t$f\n" >> /etc/hosts
# done
