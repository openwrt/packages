#!/bin/sh

case "$1" in
	pciids)
		test -s /usr/share/hwdata/pci.ids
		grep -q "^8086" /usr/share/hwdata/pci.ids
		;;
	usbids)
		test -s /usr/share/hwdata/usb.ids
		grep -q "^0781" /usr/share/hwdata/usb.ids
		;;
	pnpids)
		test -s /usr/share/hwdata/pnp.ids
		grep -q "PNP" /usr/share/hwdata/pnp.ids
		;;
esac
