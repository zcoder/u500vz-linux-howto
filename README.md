Crux 3.0 on Asus Zenbook u500vz
===============================

Intro
-----

TBD

Hardware
--------

<pre>
Processor:   Intel® Core™ i7 3612QM Processor
Chipset:     Intel® Chief River Chipset HM77
Memory:      8 GB
Display:     16:9 HD with IPS FHD (1920x1080) LED Backlight anti-glare
Graphic:     NVIDIA® GeForce® GT 650M 2GB GDDR5 VRAM
Storage:     2 x 256GB SSD RAID0 Technology
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

1. Remove all /dev/md* with `mdadm -S /dev/mdX'
2. Clear GUID partition table  of /dev/sd[ab] if exists with:
<pre>
# parted /dev/sdX
mklabel msdos
quit
</pre>
3. Make with fdisk partition scheme:
<pre>
# fdisk /dev/sda
# fdisk -l /dev/sda
# sfdisk -d /dev/sda > /tmp/ptbl.txt
# sed -i -e 's/sda/sdb/g' /tmp/ptbl.txt
# sfdisk /dev/sdb < /tmp/ptbl.txt
</pre>
4. Create software raid:
<pre>
# mdadm -C /dev/md/boot -c 128 -n 2 -e 0.9 -l 1 /dev/sda1 /dev/sdb1
# mdadm -C /dev/md/swap -c 128 -n 2 -e 0.9 -l 0 /dev/sda2 /deb/sdb2
# mdadm -C /dev/md/root -c 128 -n 2 -e 0.9 -l 0 /dev/sda3 /dev/sdb3
# mdadm -C /dev/md/home -c 128 -n 2 -e 0.9 -l 0 /dev/sda4 /dev/sdb4
</pre>
5. Create file systems:
<pre>
# mkfs.ext4 /dev/md/boot
# mkfs.ext4 /dev/md/root
# mkfs.ext4 /dev/md/home
# mkswap /dev/md/swap
</pre>
6. Mount new root:
<pre>
# mount -o noatime,nodiratime,discard,errors=remount-ro /dev/md/root /mnt
# mkdir /mnt/boot
# mount -o noatime,nodiratime,discard,errors=remount-ro /dev/md/boot /mnt/boot
# swapon /dev/md/swap
</pre>
7. Setup Crux. Notes: install mdadm and don't install xorg-video-* except xorg-video-intel.
<pre>
# setup
</pre>
8. Chroot:
<pre>
# mount --bind /dev /mnt/dev
# mount --bind /tmp /mnt/tmp
# mount -t proc proc /mnt/proc
# mount -t sysfs none /mnt/sys
# chroot /mnt /bin/bash
</pre>
9. 
