ifeq ($(findstring openwrt, $(CC)),)
ifneq ($(KERNELRELEASE),)
	wifidog-ng-objs := main.o config.o
	obj-m := wifidog-ng.o
else
	KDIR = /lib/modules/$(shell uname -r)/build

all:
	make -C $(KDIR) M=$(PWD) modules

clean:
	rm -rf *.o *.ko *.mod.c Module.* modules.* .*.cmd .tmp*

endif
else
	wifidog-ng-objs := main.o config.o
	obj-m := wifidog-ng.o
endif
