#!/bin/sh
if ! grep -qF "menuentry 'Memory Tester (memtest86+) for EFI' {" /boot/grub/grub.cfg; then
  cat /etc/grub.d/60_memtest86-efi >> /boot/grub/grub.cfg
fi
exit 0
