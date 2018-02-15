#!/bin/sh
#execute in src

. ./lns.cfg
ts=/tmp/lxcSrc.tar; td=/tmp/lxcDst.tar; lxcR="$lxcHm/$lxcNm";
sdo="ssh -i $authKey -qT -o TCPKeepAlive=yes -o ServerAliveInterval=30 -o ServerAliveCountMax=1000 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"; sd="$sdo opc@$dstSvr"; chmod 600 $authKey;
mknod $ts p; ifconfig $nifSrc mtu 1500;  $sd "sudo ifconfig $nifDst mtu 1500; sudo mknod $td p; sudo mkdir -p $lxcR;"
case $cp in 
 td) tar --numeric-owner -cvf $ts -X $exclLstFl  / 1>/tmp/tarc.log 2>&1 & dd if=$ts bs=1M | $sd "nohup sudo dd of=$td status=progress " & sleep 2; $sd "sudo tar -xvf $td -C $lxcHm/$lxcNm  1>/tmp/tarx.log 2>&1";
 $sd <<!
  sudo su - <<!!
   cat > $lxcHm/$lxcNm.cfg <<!!!
lxc.utsname=$lxcNm
lxc.pts=1
lxc.tty=4
lxc.network.type=phys
lxc.network.link=eth0
lxc.network.name = eth0
lxc.rootfs=$lxcR
!!!
   cat > $lxcHm/$lxcNm.sh <<!!!
    cd $lxcHm/; rm -f /tmp/$lxcNm.*; lxc-stop -k -n $lxcNm -o /tmp/$lxcNm.out; lxc-start -n $lxcNm -f ./$lxcNm.cfg -d -L /tmp/$lxcNm.log -o /tmp/$lxcNm.out;
!!!
   chmod +x $lxcHm/$lxcNm.sh;
   mv $lxcR/etc/sysconfig/network-scripts/ifcfg-eth0 $lxcR/etc/sysconfig/network-scripts/orig.ifcfg-eth0
   cat > $lxcR/etc/sysconfig/network-scripts/ifcfg-eth0 <<!!!
DEVICE=eth0
ONBOOT=yes
BOOTPROTO=dhcp
USERCTL=no
NM_CONTROLLED=no
!!!
 mv $lxcR/etc/fstab $lxcR/etc/fstab.orig;
 mkdir $lxcR/dev/shm; cat > $lxcR/etc/fstab <<!!!
tmpfs                   /dev/shm                tmpfs   defaults        0 0
devpts                  /dev/pts                devpts  defaults        0 0
sysfs                   /sys                    sysfs   defaults        0 0
proc                    /proc                   proc    defaults        0 0
!!!
 cp -p $lxcR/etc/rc.d/rc.sysinit $lxcR/etc/rc.d/rc.sysinit.orig; grep -v udev $lxcR/etc/rc.d/rc.sysinit.orig > $lxcR/etc/rc.d/rc.sysinit
 mv $lxcR/etc/mtab $lxcR/etc/mtab_orig
 ln -s /proc/mounts $lxcR/etc/mtab
 yum -y install lxc
 ip=\$(ip address show dev ens3 | grep inet | grep -v 127.0.0.1 | tr -s ' '  | cut -d' ' -f3 |  cut -d/ -f1);
 mv $lxcR/etc/hosts $lxcR/etc/hosts.orig; grep -v $lxcNm $lxcR/etc/hosts.orig > $lxcR/etc/hosts; echo "\$ip $lxcNm" >> $lxcHm/etc/hosts;  
 # set ulimits in host
 rm -f $lxcR/var/run/sshd.pid
 ur=\$(uname -r);
 if [[ ! -d $lxcR/lib/modules/\$ur ]]; then cp -pr /lib/modules/\$ur $lxcR/lib/modules; fi;
!!
!
;;
 rs) sed  -e "s/^\///g" $exclLstFl > /tmp/$exclLstFl.rs; rsync --rsync-path="sudo rsync" --progress -ave "$sdo" --exclude-from= /tmp/$exclLstFl.rs / opc@$dstSvr:$lxcHm/$lxcNm 1>/tmp/rsync.log 2>&1 ; ;;
esac;


