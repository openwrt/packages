# WIREGUARD_VERSION = 1.0.0-awg

ccflags-y := -D'pr_fmt(fmt)=KBUILD_MODNAME ": " fmt'
# ccflags-y += -D'WIREGUARD_VERSION="$(WIREGUARD_VERSION)"'
# ccflags-y += -DDEBUG
amneziawg-y := main.o
amneziawg-y += noise.o
amneziawg-y += device.o
amneziawg-y += peer.o
amneziawg-y += timers.o
amneziawg-y += queueing.o
amneziawg-y += send.o
amneziawg-y += receive.o
amneziawg-y += socket.o
amneziawg-y += peerlookup.o
amneziawg-y += allowedips.o
amneziawg-y += ratelimiter.o
amneziawg-y += cookie.o
amneziawg-y += netlink.o
obj-m := amneziawg.o
