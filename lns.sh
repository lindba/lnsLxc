#!/bin/sh
#execute in src

. ./lns.cfg
ts=/tmp/lxcSrc.tar; td=/tmp/lxcDst.tar; lxcR="$lxcHm/$lxcNm";
sd="ssh -i $authKey -qT -o TCPKeepAlive=yes -o ServerAliveInterval=30 -o ServerAliveCountMax=1000 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null opc@$dstSvr"; chmod 600 $authKey;
mknod $ts p; ifconfig $nifSrc mtu 1500;  $sd "sudo ifconfig $nifDst mtu 1500; sudo mknod $td p; sudo mkdir -p $lxcR;"
case $cp in 
 td) tar --numeric-owner -cvf $ts -X $exclLstFl  / 1>/tmp/tarc.log 2>&1 & dd if=$ts bs=1M | $sd "nohup sudo dd of=$td " & sleep 2; $sd "sudo tar -xvf $td -C $lxcHm/$lxcNm  1>/tmp/tarx.log 2>&1"; ;;
 rs) sed  -e "s/^\///g" $exclLstFl > $exclLstFl.rs; rsync --rsync-path="sudo rsync" --progress -ave "$sd" --exclude-from=$exclLstFl.rs 1>/tmp/rsync.log 2>&1 ; ;;
esac;

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
 mkdir $lxcR/dev/shm; cat > $lxcR/etc/fstab <<!
tmpfs                   /dev/shm                tmpfs   defaults        0 0
devpts                  /dev/pts                devpts  defaults        0 0
sysfs                   /sys                    sysfs   defaults        0 0
proc                    /proc                   proc    defaults        0 0
!
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


<<tmp
uname.sh:
src=3.10.0-327;
/bin/uname.orig $*|sed -e s/$(uname.orig -r)/$src/;

case  $1 in
-r) echo 3.8.13-44.1.1.el6uek.x86_64; ;;
-v) echo "#2 SMP Wed Sep 10 06:10:25 PDT 2014"; ;; 
-a) echo "Linux ebs.example.com 3.8.13-44.1.1.el6uek.x86_64 #2 SMP Wed Sep 10 06:10:25 PDT 2014 x86_64 x86_64 x86_64 GNU/Linux"; ;;
-n) uname_orig -n; ;;
-s) uname_orig -s; ;;
-m) uname_orig -m; ;;
-p) uname_orig -p; ;;
-i) uname_orig -i; ;;
-o) uname_orig -o; ;;
*) uname_orig ; ;;
esac;

--from ocic
chkconfig udev-post off
chkconfig oraclevm-template off


mkdir /cgroup; mount none -t cgroup /cgroup

tmp


