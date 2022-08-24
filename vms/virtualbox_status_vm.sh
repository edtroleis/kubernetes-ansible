#!/bin/bash

# ./virtualbox_status_vm.sh STATUS
# STATUS = pause|resume|reset|poweroff|savestate|startvm|restorecurrent

STATUS=$1

VMS=('k8s-master' 'k8s-worker1' 'k8s-worker2')
 
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
