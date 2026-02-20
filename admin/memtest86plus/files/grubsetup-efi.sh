#!/bin/sh
if ! grep -q memtest86 /boot/grub/grub.cfg; then
  cat /etc/grub.d/60_memtest86-efi >> /boot/grub/grub.cfg
fi
exit 0
