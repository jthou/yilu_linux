#!/bin/sh
#Disk=$1
Disk=/dev/sda
if [ $# -ne 1 ]
then 
echo
echo  "\\033[0;31m"
echo "Usage : $0 /dev/sdX"
echo "\\033[0;39m"
exit 1
fi

Disk_mounted=`cat /etc/mtab |grep $Disk |wc -l`
if [ $Disk_mounted -gt 0 ]
then
umount "$Disk"* >/dev/null 2>&1
Disk_mounted=`cat /etc/mtab |grep $Disk |wc -l`
	if [ $Disk_mounted -gt 0 ]
	then
	echo
	echo   "\\033[0;31m"
	echo "umount $Disk failed, please umount it mannually ..."
	echo   "\\033[0;39m"
	exit 1
	fi
echo
echo   "\\033[0;31m"
echo "$Disk umounted..." 
echo   "\\033[0;39m"
fi

ifswap=`cat /proc/swaps |grep $Disk |wc -l`
if [ $ifswap -gt 0 ]
then
echo
echo   "\\033[0;31m"
echo "Turn Off All Swap Partition on $Disk..."
echo   "\\033[0;39m"
swapoff -a >/dev/null 2>&1
echo
echo   "\\033[0;31m"
echo "Done!"
echo   "\\033[0;39m"
fi

echo
echo   "\\033[0;31m"
echo "Initializing partition table on $Disk ..."
echo   "\\033[0;39m"

dd if=/dev/zero of=$Disk bs=1K count=4

echo
echo   "\\033[0;31m"
echo "Done!"
echo 

echo "Creating Partition for Installation, Please wait ..." 
echo   "\\033[0;39m"

#Change the size "+37G" according to your case
fdisk $Disk <<ARGS
n
p
1

+37G
n
p
2


t
2
82
w
ARGS

fdisk -l $Disk
sleep 5 
partprobe $Disk

echo
echo   "\\033[0;31m"
echo "Creating swap partition ..."
echo   "\\033[0;39m"
mkswap "$Disk"2
	if [ $? -ne 0 ]
	then
	echo
	echo   "\\033[0;31m"
	echo "Turn Off swap failed ..."
	echo   "\\033[0;39m"
	exit 1
	fi
swapon "$Disk"2
	if [ $? -ne 0 ]
	then
	echo
	echo   "\\033[0;31m"
	echo "Turn Off swap failed ..."
	echo   "\\033[0;39m"
	exit 1
	fi
echo
echo   "\\033[0;31m"
echo "Done!"
echo
echo   "\\033[0;31m"
echo "Creating Root File System on $Disk ..."
echo   "\\033[0;39m"
mkfs.ext4 "$Disk"1
echo
echo   "\\033[0;31m"
echo "Done!"
echo   "\\033[0;39m"

rm -rf /mnt/Disk
mkdir /mnt/Disk
	if [ $? -ne 0 ]
	then
	echo
	echo   "\\033[0;31m"
	echo "Create mount point failed! ..." 
	echo   "\\033[0;39m"
	exit 1
	fi
mount "$Disk"1 /mnt/Disk 
	if [ $? -ne 0 ]
	then
	echo
	echo   "\\033[0;31m"
	echo "mount partition failed! ..." 
	echo   "\\033[0;39m"
	exit 1
	fi
echo
echo   "\\033[0;31m"
echo "Copying Files, please wait ..."
echo   "\\033[0;39m"
tar zxvf deepin2-1.tar.gz -C /mnt/Disk >/dev/null
#	if [ $? -ne 0 ]
#	then
#	echo
#	echo   "\\033[0;31m"
#	echo "Copy files failed, please check the source file ..." 
#	echo   "\\033[0;39m"
#	exit 1
#	fi
echo
echo   "\\033[0;31m"
echo "Done!"
echo   "\\033[0;39m"

cd /mnt/Disk
mkdir dev media mnt proc run srv sys tmp
cd /
#exit 0
#echo ""$Disk"1 / ext4 rw 0 0
#proc /proc proc rw 0 0
#sysfs /sys sysfs rw 0 0
#devpts /dev/pts devpts rw,gid=5,mode=620 0 0
#tmpfs /dev/shm tmpfs rw 0 0
#none /proc/sys/fs/binfmt_misc binfmt_misc rw 0 0">/mnt/Disk/etc/mtab

mount --bind /dev/ /mnt/Disk/dev
Partition=`echo $Disk |awk -F "/" '{print $3}'` 
for i in 2 1
do 
echo  "Get UUID of $Disk$i ..."
UUID=`ls -l /dev/disk/by-uuid/ |grep $Partition$i |awk '{print $9}'`

echo "$Disk$i UUID is: "

echo $UUID

#sed -i.bak "s/\/dev\/sda$i/UUID=$UUID/g" /mnt/Disk/etc/fstab
#rm -rf /mnt/Disk/etc/fstab.bak

echo "UUID=$UUID / ext4 rw,relatime 0 1 
UUID=$UUID none swap defaults,pri=-2 0 0 " >/mnt/Disk/etc/fstab

i=`expr $i - 1`
done

i=`expr $i + 1`
echo "$Partition$i UUID is $UUID"

# Replace the following UUID "1a193cf5-bd27-4fae-b030-0d038ffe6354" with the one in your tar.gz grub.cfg
sed -i.bak s/31f447a4-6e1a-4114-a0be-a7460f2bc3ee/$UUID/g /mnt/Disk/boot/grub/grub.cfg
rm -rf /mnt/Disk/boot/grub/grub.cfg.bak


mount --bind /proc/ /mnt/Disk/proc

echo
echo   "\\033[0;31m"
echo "Install Bootloader on $Disk, Please wait ..." 
echo   "\\033[0;39m"
chroot /mnt/Disk /bin/bash -c "/sbin/grub-install $Disk"
echo
echo   "\\033[0;31m"
echo "Done!" 

echo 
echo "All Done!"
echo "Please remove all other medias and reboot the system with Ctrl+Alt+Del"
echo   "\\033[0;39m"

