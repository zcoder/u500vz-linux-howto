Crux 3.0 on Asus Zenbook u500vz/ux51vz
======================================

TBD

Hardware
--------

<pre>
Processor:   Intel® Core™ i7 3612QM Processor
Chipset:     Intel® Chief River Chipset HM77
Memory:      8 GB
Display:     16:9 HD with IPS FHD (1920x1080) LED Backlight anti-glare
Graphic:     NVIDIA® GeForce® GT 650M 2GB GDDR5 VRAM
Storage:     2 x 256GB SSD A-Data XM11 (RAID0 Technology)
Card Reader: 2-in-1 card reader (SD/MMC)
Camera:	     HD 720p CMOS with Array Microphone
Wifi & BT:   Intel Advanced-N 6235(dual band, 2x2 Wi-Fi/BT combo HMC module)
Ethernet:    Atheros AR8151 Gigabit
Audio:       Built-in Speakers And Microphone (Additional subwoofer)
USB ports:   3 x 3.0
HDMI:        1
Mini VGA:    1
</pre>

Status
------
<pre>
Processor:   Works
Chipset:     Works
Memory:      Works
Graphic:     Works
Storage:     Works
Card Reader: Not Tested
Camera:      Not Tested
Wifi:        Works
BT:          Not Tested
Ethernet:    Works
Audio:       Not Tested
USB ports:   Works (as 2.0, 3.0 Not Tested)
HDMI:        Not Tested
Mini VGA:    Not Tested
</pre>

Preparation
-----------

TBD

Installation
------------

### Partitions

1. Remove all /dev/md* with `mdadm -S /dev/mdX'
2. Clear GUID partition table  of /dev/sd[ab] if exists with:
<pre>
# parted /dev/sdX
mklabel msdos
quit
</pre>
3. Make with fdisk the partition scheme. For the first partition you need to choose cylinder number 2 for the start,
since the first cylinder is needed for the MBR and bootloader.
<pre>
# fdisk -H 224 -S 56 /dev/sda
# fdisk -l /dev/sda
... TBD ...
# sfdisk -d /dev/sda | sed 's/sda/sdb/g' > /tmp/tbl
# sfdisk /dev/sdb < /tmp/tbl
</pre>
4. Create software raid:
<pre>
# mdadm -C /dev/md0 -n 2 -e 0.9 -l 1 /dev/sda1 /dev/sdb1
# mdadm -C /dev/md1 -c 128 -n 2 -e 0.9 -l 0 /dev/sda2 /deb/sdb2
# mdadm -C /dev/md2 -c 128 -n 2 -e 0.9 -l 0 /dev/sda3 /dev/sdb3
# mdadm -C /dev/md3 -c 128 -n 2 -e 0.9 -l 0 /dev/sda4 /dev/sdb4
</pre>

### Setup Crux

1. Create file systems:
<pre>
# mkfs.ext4 /dev/md0
# mkfs.ext4 /dev/md2
# mkfs.ext4 /dev/md3
# mkswap /dev/md1
</pre>
2. Mount the new root:
<pre>
# mount -o noatime,nodiratime,discard,errors=remount-ro /dev/md2 /mnt
# mkdir /mnt/boot
# mount -o noatime,nodiratime,discard,errors=remount-ro /dev/md0 /mnt/boot
</pre>
3. Setup Crux. Note: install mdadm and don't install xorg-xf86-video-* except xorg-xf86-video-intel.
<pre>
# setup
</pre>
4. Create /mnt/etc/mdadm.conf:
<pre>
DEVICE partitions
CREATE owner=root group=disk mode=0600 auto=yes
HOMEHOST <system>
MAILADDR root
</pre>
Add arrays:
<pre>
# mdadm --detail --scan >> /mnt/etc/mdadm.conf
</pre>
6. Make chroot:
<pre>
# mount --bind /dev /mnt/dev
# mount --bind /tmp /mnt/tmp
# mount -t proc proc /mnt/proc
# mount -t sysfs none /mnt/sys
# chroot /mnt /bin/bash
</pre>

### Base configuration

1. Set root password.
2. There are virtual memory settings for SSD. Edit /etc/sysctl.conf:
<pre>
vm.swappiness = 1
vm.vfs_cache_pressure = 25
vm.dirty_ratio = 40
vm.dirty_background_ratio = 3
</pre>
3. Edit /etc/fstab
<pre>
devpts                 /dev/pts  devpts    defaults               0      0
tmpfs                  /tmp      tmpfs     defaults               0      0
tmpfs                  /var/log  tmpfs     defaults               0      0
tmpfs                  /var/spool  tmpfs   defaults               0      0
tmpfs                  /var/tmp  tmpfs     defaults               0      0
tmpfs                  /dev/shm  tmpfs     defaults               0      0
/dev/md0               /boot     ext4      noatime,nodiratime,discard,errors=remount-ro 0 1
/dev/md2               /         ext4      noatime,nodiratime,discard,errors=remount-ro 0 1
/dev/md3               /home     ext4      noatime,nodiratime,discard,errors=remount-ro 0 1
/dev/md1               swap      swap      defaults               0      0
</pre>
4. Edit /etc/rc.conf
5. Remove eth0 from /etc/rc.d/net

### Linux kernel and Lilo

1. Build linux kernel with [config](config):
<pre>
# cd /usr/src/linux-3.6.11
# make menuconfig
# make all
# make modules_install
# cp arch/x86/boot/bzImage /boot/vmlinuz
# cp System.map /boot
</pre>

2. Edit /etc/lilo.conf:

<pre><code>lba32
boot=/dev/md0
vga=normal
raid-extra-boot=auto
image=/boot/vmlinuz
    label=CRUX
    append="root=/dev/md2 rootfstype=ext4 md=2,0,5,0,/dev/sda3,/dev/sdb3 quiet"
    read-only
</code></pre>

3. Run lilo:
<pre>
# lilo
# lilo -M /dev/sda
# lilo -M /dev/sdb
</pre>

### Reboot

Postinstallation
================

### Ethernet
Kernel driver: atl1c
<pre>
# ip link set eth0 up
# dhcpcd -t 10 eth0
</pre>

### Ports
<pre>
# mv /etc/contrib.rsync{.inactive,}
# ports -u
</pre>
Uncomment contrib in /etc/prt-get.conf

### Wifi

<pre>
# prt-get install iw
</pre>
If it returns 404, then:
<pre>
# cp /etc/pkgmk.conf /tmp
# echo 'PKGMK_SOURCE_MIRRORS=(http://kernel.org/pub/software/network/iw/)' >> /tmp/pkgmk.conf
# prt-get install --margs='-cf /tmp/pkgmk.conf' iw
</pre>

Copy [iwlwifi-6000g2b-6.ucode](http://wireless.kernel.org/en/users/Drivers/iwlwifi?action=AttachFile&do=get&target=iwlwifi-6000g2b-ucode-18.168.6.1.tgz) into /lib/firmware. Then:

<pre>
# rmmod iwlwifi
# modprobe iwlwifi
# ip link set wlan0 up
</pre>

### Graphic
1. Xorg
2. NVIDIA
3. Bumblebee
4. bbswitch


