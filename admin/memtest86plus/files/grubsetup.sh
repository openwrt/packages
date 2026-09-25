#!/bin/sh
if ! grep -qF "menuentry 'Memory Tester (memtest86+)' {" /boot/grub/grub.cfg; then
  cat /etc/grub.d/60_memtest86 >> /boot/grub/grub.cfg
fi
exit 0
