#!/usr/bin/env bash

set -euo pipefail

# To set the keyboard layout and console font, and connect to the network:
#
#    loadkeys colemak
#    setfont ter-124b
#    iwctl station wlan0 connect <SSID>

read -rp "Passphrase: " PASSPHRASE
read -rp "Hostname: " HOSTNAME

info() {
  echo -e "\033[1;34m::\033[0m \033[1;37m$*\033[0m"
}

# 1.8 Update the system clock
info "Updating system clock..."
timedatectl set-ntp true

# 1.9 Partition the disks
info "Partitioning disks..."
sfdisk /dev/sda <<EOF
label: gpt
/dev/sda1: size=1GiB, type=uefi
/dev/sda2: type=linux
EOF

# 1.10 Format the partitions
info "Formatting partitions..."
mkfs.fat -F 32 /dev/sda1
echo -n "$PASSPHRASE" | cryptsetup luksFormat /dev/sda2 -
echo -n "$PASSPHRASE" | cryptsetup open /dev/sda2 root --key-file -
mkfs.ext4 /dev/mapper/root

# 1.11 Mount the file systems
info "Mounting file systems..."
mount /dev/mapper/root /mnt
mount --mkdir /dev/sda1 /mnt/boot

PARTUUID="$(lsblk -no PARTUUID /dev/sda2)"

# 2.1 Select the mirrors
info "Selecting mirrors..."
reflector --country "United Kingdom" --protocol https --sort rate \
  --save /etc/pacman.d/mirrorlist

# 2.2 Install essential packages
info "Installing essential packages..."
sed -i -e "s/^#Color/Color/" -e "s/^#ParallelDownloads/ParallelDownloads/" \
  /etc/pacman.conf
pacstrap -KP /mnt base linux linux-lts linux-firmware intel-ucode efibootmgr \
  sudo man-db man-pages iwd terminus-font zram-generator vi

# 3.1 Fstab
info "Generating fstab..."
genfstab -U /mnt >>/mnt/etc/fstab

# 3.2 Chroot
info "Configuring system in chroot..."
cat >/mnt/install-arch-chroot.sh <<EOF
info() {
  echo -e "\033[1;34m::\033[0m \033[1;37m\$*\033[0m"
}

# 3.3 Time
info "Setting timezone and enabling synchronisation..."
ln -s /usr/share/zoneinfo/Europe/London /etc/localtime
hwclock --systohc
systemctl enable systemd-timesyncd

# 3.4 Localisation
info "Configuring locale..."
sed -i "s/^#en_GB.UTF-8/en_GB.UTF_8/" /etc/locale.gen
locale-gen
echo "LANG=en_GB.UTF-8" >/etc/locale.conf
cat >/etc/vconsole.conf <<EOF2
FONT=ter-124b
KEYMAP=colemak
EOF2

# 3.5 Network configuration
info "Configuring networking..."
echo "$HOSTNAME" >/etc/hostname
mkdir -p /etc/iwd
cat >/etc/iwd/main.conf <<EOF2
[General]
EnableNetworkConfiguration=true
EOF2
systemctl enable iwd
systemctl enable systemd-networkd
systemctl enable systemd-resolved

# 3.6 Initramfs
info "Generating initramfs..."
sed -i -e "s/^MODULES=()/MODULES=(usbhid xhci_hcd)/" \
  -e "/^HOOKS=/s/filesystems/encrypt filesystems/" /etc/mkinitcpio.conf
mkinitcpio -P

# 3.7 Root password
info "Setting root passphrase..."
echo "root:$PASSPHRASE" | chpasswd

# 3.8 Boot loader
info "Configuring boot loader..."
mkdir -p /boot/loader/entries
cat >/boot/loader/loader.conf <<EOF2
timeout 3
default arch-linux
EOF2

cat >/boot/loader/entries/arch-linux.conf <<EOF2
title Arch Linux
linux /vmlinuz-linux
initrd /intel-ucode.img
initrd /initramfs-linux.img
options cryptdevice=PARTUUID=$PARTUUID:root root=/dev/mapper/root zswap.enabled=0 rw rootfstype=ext4
EOF2

cat >/boot/loader/entries/arch-linux-fallback.conf <<EOF2
title Arch Linux (fallback)
linux /vmlinuz-linux
initrd /intel-ucode.img
initrd /initramfs-linux-fallback.img
options cryptdevice=PARTUUID=$PARTUUID:root root=/dev/mapper/root zswap.enabled=0 rw rootfstype=ext4
EOF2

cat >/boot/loader/entries/arch-linux-lts.conf <<EOF2
title Arch Linux LTS
linux /vmlinuz-linux-lts
initrd /intel-ucode.img
initrd /initramfs-linux-lts.img
options cryptdevice=PARTUUID=$PARTUUID:root root=/dev/mapper/root zswap.enabled=0 rw rootfstype=ext4
EOF2

cat >/boot/loader/entries/arch-linux-lts-fallback.conf <<EOF2
title Arch Linux LTS (fallback)
linux /vmlinuz-linux-lts
initrd /intel-ucode.img
initrd /initramfs-linux-lts-fallback.img
options cryptdevice=PARTUUID=$PARTUUID:root root=/dev/mapper/root zswap.enabled=0 rw rootfstype=ext4
EOF2

bootctl install
systemctl enable systemd-boot-update

info "Enabling fstrim..."
systemctl enable fstrim.timer

info "Enabling swap on zram..."
cat >/etc/systemd/zram-generator.conf <<EOF2
[zram0]
EOF2

info "Creating user account..."
useradd -G wheel -m scott
echo "scott:$PASSPHRASE" | chpasswd

info "Granting sudo access to wheel group..."
sed -i "s/^# \(%wheel ALL=(ALL:ALL) ALL\)$/\1/" /etc/sudoers
EOF

arch-chroot /mnt /bin/bash /install-arch-chroot.sh
rm /mnt/install-arch-chroot.sh

# 4 Reboot
info "Unmounting disks..."
umount -R /mnt
