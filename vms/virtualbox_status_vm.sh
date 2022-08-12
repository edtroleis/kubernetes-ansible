#!/bin/bash

# ./virtualbox_status_vm.sh STATUS
# STATUS = pause|resume|reset|poweroff|savestate|startvm

STATUS=$1

VMS=('k8smaster' 'k8sworker1' 'k8sworker2')
 
for vm in "${VMS[@]}"
do
  echo "[$vm] -> $STATUS..."

  if [ $STATUS == "startvm" ]; then
    VBoxManage.exe startvm $vm
  else
    VBoxManage.exe controlvm $vm $STATUS
  fi
done
