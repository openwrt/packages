#!/bin/sh

case "$1" in
	pciids)
		test -s /usr/share/hwdata/pci.ids
		;;
	usbids)
		test -s /usr/share/hwdata/usb.ids
		;;
	pnpids)
		test -s /usr/share/hwdata/pnp.ids
		;;
esac
