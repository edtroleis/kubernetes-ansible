#!/bin/bash

# ./virtualbox_status_vm.sh STATUS
# STATUS = pause|resume|reset|poweroff|savestate|startvm|restorecurrent

STATUS=$1

VMS=('kube-master' 'kube-worker1' 'kube-worker2')
 
for vm in "${VMS[@]}"
do
  echo "[$vm] -> $STATUS..."

  if [ $STATUS == "startvm" ]; then
    VBoxManage.exe startvm $vm
  elif [ $STATUS == "restorecurrent" ]; then
    VBoxManage.exe snapshot $vm restorecurrent
  else
    VBoxManage.exe controlvm $vm $STATUS
  fi
done
