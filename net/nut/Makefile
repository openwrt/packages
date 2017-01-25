#
# Copyright (C) 2006-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=nut
PKG_VERSION:=2.7.4
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://www.networkupstools.org/source/2.7/
PKG_MD5SUM:=3ba53656933d7471f95140b32a5b8d5c
PKG_MAINTAINER:=Martin Rowe <martin.p.rowe@gmail.com>
PKG_LICENSE:=GPL-2.0
PKG_LICENSE_FILES:=LICENSE-GPL2

PKG_BUILD_DIR:=$(BUILD_DIR)/nut-$(PKG_VERSION)
PKG_INSTALL:=1

PKG_CONFIG_DEPENDS:= \
	CONFIG_NUT_CLIENTS_UPSC \
	CONFIG_NUT_CLIENTS_UPSCMD \
	CONFIG_NUT_CLIENTS_UPSLOG \
	CONFIG_NUT_CLIENTS_UPSMON \
	CONFIG_NUT_CLIENTS_UPSRW \
	CONFIG_NUT_CLIENTS_UPSSCHED \
	CONFIG_NUT_DRIVER_SNMP \
	CONFIG_NUT_DRIVER_USB \
	CONFIG_NUT_SERVER \
	CONFIG_NUT_SSL

include $(INCLUDE_DIR)/package.mk

define Package/nut/Default
	SECTION:=net
	CATEGORY:=Network
	URL:=http://www.networkupstools.org/
	DEPENDS:=nut
endef

define Package/nut/description
Network UPS Tools (NUT) is a client/server monitoring system that
allows computers to share uninterruptible power supply (UPS) and
power distribution unit (PDU) hardware. Clients access the hardware
through the server, and are notified whenever the power status
changes.
endef

define Package/nut
	$(call Package/nut/Default)
	TITLE:=Network UPS Tools
	DEPENDS:= \
		+libpthread \
		+NUT_DRIVER_SNMP:libnetsnmp \
		+NUT_DRIVER_USB:libusb-compat \
		+NUT_SSL:libopenssl
	MENU:=1
endef

define Package/nut/config
	source "$(SOURCE)/Config.in"
endef

define Package/nut/conffiles
/etc/nut/nut.conf
$(if $(CONFIG_NUT_CLIENTS_UPSMON),/etc/nut/upsmon.conf)
$(if $(CONFIG_NUT_CLIENTS_UPSSCHED),/etc/nut/upssched.conf)
$(if $(CONFIG_NUT_SERVER),/etc/nut/ups.conf)
$(if $(CONFIG_NUT_SERVER),/etc/nut/upsd.conf)
$(if $(CONFIG_NUT_SERVER),/etc/nut/upsd.users)
endef

define Package/nut/install
	$(INSTALL_DIR) $(1)/etc/nut
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_CONF) $(PKG_INSTALL_DIR)/etc/nut/nut.conf.sample $(1)/etc/nut/nut.conf
	$(if $(or $(CONFIG_NUT_CLIENTS_UPSC),\
		$(CONFIG_NUT_CLIENTS_UPSCMD),\
		$(CONFIG_NUT_CLIENTS_LOG),\
		$(CONFIG_NUT_CLIENTS_UPSRW),\
		$(CONFIG_NUT_CLIENTS_UPSMON),\
		$(CONFIG_NUT_CLIENTS_UPSSCHED)),$(CP) $(PKG_INSTALL_DIR)/usr/lib/libupsclient.so* $(1)/usr/lib/)
	$(if $(or $(CONFIG_NUT_SERVER),\
		$(CONFIG_NUT_CLIENTS_UPSMON)),$(INSTALL_DIR) $(1)/etc/init.d)
	$(if $(CONFIG_NUT_SERVER),$(INSTALL_DIR) $(1)/lib/nut)
	$(if $(CONFIG_NUT_SERVER),$(INSTALL_DIR) $(1)/usr/share/nut)
	$(if $(CONFIG_NUT_SERVER),$(CP) ./files/nut-server.init $(1)/etc/init.d/)
	$(if $(CONFIG_NUT_SERVER),$(CP) $(PKG_INSTALL_DIR)/usr/sbin/upsd $(1)/usr/sbin)
	$(if $(CONFIG_NUT_SERVER),$(CP) $(PKG_INSTALL_DIR)/usr/sbin/upsdrvctl $(1)/usr/sbin)
	$(if $(CONFIG_NUT_SERVER),$(CP) $(PKG_INSTALL_DIR)/usr/share/nut/cmdvartab $(1)/usr/share/nut/)
	$(if $(CONFIG_NUT_SERVER),$(CP) $(PKG_INSTALL_DIR)/usr/share/nut/driver.list $(1)/usr/share/nut/)
	$(if $(CONFIG_NUT_SERVER),$(INSTALL_CONF) $(PKG_INSTALL_DIR)/etc/nut/ups.conf.sample $(1)/etc/nut/ups.conf)
	$(if $(CONFIG_NUT_SERVER),$(INSTALL_CONF) $(PKG_INSTALL_DIR)/etc/nut/upsd.conf.sample $(1)/etc/nut/upsd.conf)
	$(if $(CONFIG_NUT_SERVER),$(INSTALL_CONF) $(PKG_INSTALL_DIR)/etc/nut/upsd.users.sample $(1)/etc/nut/upsd.users)
	$(if $(CONFIG_NUT_CLIENTS_UPSC),$(CP) $(PKG_INSTALL_DIR)/usr/bin/upsc $(1)/usr/bin/)
	$(if $(CONFIG_NUT_CLIENTS_UPSCMD),$(CP) $(PKG_INSTALL_DIR)/usr/bin/upscmd $(1)/usr/bin/)
	$(if $(CONFIG_NUT_CLIENTS_UPSLOG),$(CP) $(PKG_INSTALL_DIR)/usr/bin/upslog $(1)/usr/bin/)
	$(if $(CONFIG_NUT_CLIENTS_UPSRW),$(CP) $(PKG_INSTALL_DIR)/usr/bin/upsrw $(1)/usr/bin/)
	$(if $(CONFIG_NUT_CLIENTS_UPSMON),$(CP) ./files/nut-monitor.init $(1)/etc/init.d/)
	$(if $(CONFIG_NUT_CLIENTS_UPSMON),$(CP) $(PKG_INSTALL_DIR)/usr/sbin/upsmon $(1)/usr/sbin/)
	$(if $(CONFIG_NUT_CLIENTS_UPSMON),$(INSTALL_CONF) $(PKG_INSTALL_DIR)/etc/nut/upsmon.conf.sample $(1)/etc/nut/upsmon.conf)
	$(if $(CONFIG_NUT_CLIENTS_UPSSCHED),$(CP) $(PKG_INSTALL_DIR)/usr/bin/upssched-cmd $(1)/usr/bin/)
	$(if $(CONFIG_NUT_CLIENTS_UPSSCHED),$(CP) $(PKG_INSTALL_DIR)/usr/sbin/upssched $(1)/usr/sbin/)
	$(if $(CONFIG_NUT_CLIENTS_UPSSCHED),$(INSTALL_CONF) $(PKG_INSTALL_DIR)/etc/nut/upssched.conf.sample $(1)/etc/nut/upssched.conf)
endef

define Package/nut-web-cgi
	$(call Package/nut/Default)
	TITLE+= Web CGI interface
	DEPENDS+=+libgd
endef

define Package/nut-web-cgi/description
The CGI programs are clients that run through your web server.
They allow you to see UPS status and perform certain administrative
commands from any web browser. Javascript and cookies are not required.
endef

define Package/nut-web-cgi/conffiles
/etc/nut/hosts.conf
/etc/nut/upsset.conf
/etc/nut/upsstats.html
/etc/nut/upsstats-single.html
endef

define Package/nut-web-cgi/install
	$(INSTALL_DIR) $(1)/etc/nut
	$(INSTALL_DIR) $(1)/usr/share/www/cgi-bin
	$(INSTALL_CONF) $(PKG_INSTALL_DIR)/etc/nut/hosts.conf.sample $(1)/etc/nut/hosts.conf
	$(INSTALL_CONF) $(PKG_INSTALL_DIR)/etc/nut/upsset.conf.sample $(1)/etc/nut/upsset.conf
	$(INSTALL_CONF) $(PKG_INSTALL_DIR)/etc/nut/upsstats.html.sample $(1)/etc/nut/upsstats.html
	$(INSTALL_CONF) $(PKG_INSTALL_DIR)/etc/nut/upsstats-single.html.sample $(1)/etc/nut/upsstats-single.html
	$(CP) $(PKG_INSTALL_DIR)/usr/share/www/nut $(1)/usr/share/www/
	$(CP) $(PKG_INSTALL_DIR)/usr/share/www/cgi-bin/nut $(1)/usr/share/www/cgi-bin/
endef

define Package/nut-avahi-service
	$(call Package/nut/Default)
	TITLE+= (Avahi service)
	DEPENDS+=+avahi-daemon
endef

define Package/nut-avahi-service/description
This package contains the service definition for announcing the
attached UPS via mDNS/DNS-SD.
endef

define Package/nut-avahi-service/conffiles
/etc/avahi/services/nut.service
endef

define Package/nut-avahi-service/install
	$(INSTALL_DIR) $(1)/etc/avahi/services
	$(INSTALL_CONF) ./files/nut.service $(1)/etc/avahi/services/
endef

# Dealing with all of the drivers is very repetitive, but the previous
# maintainer had a neat solution which just needed some tweaking.
define DriverPackage
        define Package/nut-driver-$(2)
		$(call Package/nut/Default)
		TITLE:=$(2) (NUT $(1) driver)
		$(if $(filter $(1),snmp),DEPENDS+= @NUT_DRIVER_SNMP)
		$(if $(filter $(1),usb),DEPENDS+= @NUT_DRIVER_USB)
        endef
	# Deliberately empty description in order to trigger a build failure.
	# It should be overridden by the list below, and when updating to a
	# new version of nut we will need to provide descriptions for any new
	# drivers.
        define Package/nut-driver-$(2)/description
		
        endef
        define Package/nut-driver-$(2)/install
        	$(INSTALL_DIR) $$(1)/lib/nut
		$(CP) $$(PKG_INSTALL_DIR)/lib/nut/$(2) $$(1)/lib/nut/
		$(if $(filter $(2),clone),$(CP) $$(PKG_INSTALL_DIR)/lib/nut/$(2)-outlet $$(1)/lib/nut/)
        endef
endef
define DriverDescription
        define Package/nut-driver-$(2)/description
		$(3)
        endef
endef
# These lists are lifted *directly* from drivers/Makefile.am in the nut
# source tree. This it to make it simpler to keep in sync when updating
# to a newer version of nut. Do not edit this manually.
#
# DO NOT EDIT (except to update with a fresh cut/paste)!
SERIAL_DRIVERLIST = al175 bcmxcp belkin belkinunv bestfcom	\
 bestfortress bestuferrups bestups dummy-ups etapro everups	 \
 gamatronic genericups isbmex liebert liebert-esp2 masterguard metasys	\
 oldmge-shut mge-utalk microdowell mge-shut oneac optiups powercom rhino	 \
 safenet skel solis tripplite tripplitesu upscode2 victronups powerpanel \
 blazer_ser clone clone-outlet ivtscd apcsmart apcsmart-old apcupsd-ups riello_ser	\
 nutdrv_qx
SNMP_DRIVERLIST = snmp-ups
USB_LIBUSB_DRIVERLIST = usbhid-ups bcmxcp_usb tripplite_usb \
 blazer_usb richcomm_usb riello_usb \
 nutdrv_atcl_usb \
 nutdrv_qx
# END: DO NOT EDIT!
SERIAL_DRIVERLIST_IGNORE:=skel clone-outlet nutdrv_qx
# nutdrv_qx can be either USB or serial. Given most routers have USB
# instead of serial ports, and not wanting two identical packages with
# different names that conflict with each other, only the option for the
# driver with USB bindings is provided. If you really want to save that
# tiny bit of space and build it without USB support, remove nutdrv_qx
# from the previous line.

$(foreach d,$(filter-out $(SERIAL_DRIVERLIST_IGNORE),$(SERIAL_DRIVERLIST)),$(eval $(call DriverPackage,serial,$(d))))
$(foreach d,$(SNMP_DRIVERLIST),$(eval $(call DriverPackage,snmp,$(d))))
$(foreach d,$(USB_LIBUSB_DRIVERLIST),$(eval $(call DriverPackage,usb,$(d))))

$(eval $(call DriverDescription,serial,al175,\
	Driver for Eltek UPS models with AL175 alarm module))
$(eval $(call DriverDescription,serial,bcmxcp,\
	Driver for UPSes supporting the serial BCM/XCP protocol))
$(eval $(call DriverDescription,serial,belkin,\
	Driver for Belkin serial UPS equipment))
$(eval $(call DriverDescription,serial,belkinunv,\
	Driver for Belkin "Universal UPS" and compatible))
$(eval $(call DriverDescription,serial,bestfcom,\
	Driver for Best Power Fortress/Ferrups))
$(eval $(call DriverDescription,serial,bestfortress,\
	Driver for old Best Fortress UPS equipment))
$(eval $(call DriverDescription,serial,bestuferrups,\
	Driver for Best Power Micro-Ferrups))
$(eval $(call DriverDescription,serial,bestups,\
	Driver for Best Power / SOLA (Phoenixtec protocol) UPS equipment))
$(eval $(call DriverDescription,serial,dummy-ups,\
	Driver for multi-purpose UPS emulation))
$(eval $(call DriverDescription,serial,etapro,\
	Driver for ETA UPS equipment))
$(eval $(call DriverDescription,serial,everups,\
	Driver for Ever UPS models))
$(eval $(call DriverDescription,serial,gamatronic,\
	Driver for Gamatronic UPS equipment))
$(eval $(call DriverDescription,serial,genericups,\
	Driver for contact-closure UPS equipment))
$(eval $(call DriverDescription,serial,isbmex,\
	Driver for ISBMEX UPS equipment))
$(eval $(call DriverDescription,serial,liebert,\
	Driver for Liebert contact-closure UPS equipment))
$(eval $(call DriverDescription,serial,liebert-esp2,\
	Driver for Liebert UPS, using the ESP-II serial protocol))
$(eval $(call DriverDescription,serial,masterguard,\
	Driver for Masterguard UPS equipment))
$(eval $(call DriverDescription,serial,metasys,\
	Driver for Meta System UPS equipment))
$(eval $(call DriverDescription,serial,oldmge-shut,\
	Driver for SHUT Protocol UPS equipment, deprecated, use mge-shut))
$(eval $(call DriverDescription,serial,mge-utalk,\
	Driver for MGE UPS SYSTEMS UTalk protocol equipment))
$(eval $(call DriverDescription,serial,microdowell,\
	Driver for Microdowell Enterprise UPS series))
$(eval $(call DriverDescription,serial,mge-shut,\
	Driver for SHUT Protocol UPS equipment))
$(eval $(call DriverDescription,serial,oneac,\
	Driver for Oneac UPS equipment))
$(eval $(call DriverDescription,serial,optiups,\
	Driver for Opti-UPS (Viewsonic) UPS and Zinto D (ONLINE-USV) equipment))
$(eval $(call DriverDescription,serial,powercom,\
	Driver for serial Powercom/Trust/Advice UPS equipment))
$(eval $(call DriverDescription,serial,rhino,\
	Driver for Brazilian Microsol RHINO UPS equipment))
$(eval $(call DriverDescription,serial,safenet,\
	Driver for SafeNet compatible UPS equipment))
$(eval $(call DriverDescription,serial,solis,\
	Driver for Brazilian Microsol SOLIS UPS equipment))
$(eval $(call DriverDescription,serial,tripplite,\
	Driver for Tripp-Lite SmartPro UPS equipment))
$(eval $(call DriverDescription,serial,tripplitesu,\
	Driver for Tripp-Lite SmartOnline (SU) UPS equipment))
$(eval $(call DriverDescription,serial,upscode2,\
	Driver for UPScode II compatible UPS equipment))
$(eval $(call DriverDescription,serial,victronups,\
	Driver for IMV/Victron UPS unit Match, Match Lite, NetUps))
$(eval $(call DriverDescription,serial,powerpanel,\
	Driver for PowerPanel Plus compatible UPS equipment))
$(eval $(call DriverDescription,serial,blazer_ser,\
	Driver for Megatec/Q1 protocol serial based UPS equipment))
$(eval $(call DriverDescription,serial,clone,\
	UPS driver clone))
$(eval $(call DriverDescription,serial,ivtscd,\
	Driver for the IVT Solar Controller Device))
$(eval $(call DriverDescription,serial,apcsmart,\
	Driver for American Power Conversion Smart Protocol UPS equipment))
$(eval $(call DriverDescription,serial,apcsmart-old,\
	Driver for American Power Conversion Smart Protocol UPS equipment))
$(eval $(call DriverDescription,serial,apcupsd-ups,\
	Driver for apcupsd client access))
$(eval $(call DriverDescription,serial,riello_ser,\
	Driver for Riello UPS Protocol UPS equipment))
$(eval $(call DriverDescription,snmp,snmp-ups,\
	Multi-MIB Driver for SNMP UPS equipment))
$(eval $(call DriverDescription,usb,usbhid-ups,\
	Driver for USB/HID UPS equipment))
$(eval $(call DriverDescription,usb,bcmxcp_usb,\
	Experimental driver for UPSes supporting the BCM/XCP protocol over USB))
$(eval $(call DriverDescription,usb,tripplite_usb,\
	Driver for older Tripp Lite USB UPSes (not PDC HID)))
$(eval $(call DriverDescription,usb,blazer_usb,\
	Driver for Megatec/Q1 protocol USB based UPS equipment))
$(eval $(call DriverDescription,usb,richcomm_usb,\
	Driver for UPS equipment using Richcomm dry-contact to USB solution))
$(eval $(call DriverDescription,usb,riello_usb,\
	Driver for Riello UPS Protocol UPS equipment via USB))
$(eval $(call DriverDescription,usb,nutdrv_atcl_usb,\
	Driver for ATCL FOR UPS equipment))
$(eval $(call DriverDescription,usb,nutdrv_qx,\
	Driver for Q* protocol serial and USB based UPS equipment))

CONFIGURE_ARGS += \
	--sysconfdir=/etc/nut \
	--datadir=/usr/share/nut \
	--with-dev \
	--$(if $(CONFIG_NUT_DRIVER_USB),with,without)-usb \
	--without-avahi \
	--$(if $(CONFIG_NUT_DRIVER_SNMP),with,without)-snmp \
	--without-neon \
	--without-powerman \
	--without-ipmi \
	--without-freeipmi \
	--$(if $(CONFIG_NUT_SSL),with,without)-ssl $(if $(CONFIG_NUT_SSL),--with-openssl) \
	--without-libltdl \
	--$(if $(CONFIG_PACKAGE_nut-web-cgi),with,without)-cgi \
	--with-statepath=/var/run \
	--with-drvpath=/lib/nut \
	--with-cgipath=/usr/share/www/cgi-bin/nut \
	--with-htmlpath=/usr/share/www/nut \
	--with-user=root \
	--with-group=root

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/lib*.so* $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/include/*.h $(1)/usr/include/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/*.pc $(1)/usr/lib/pkgconfig/
endef

$(eval $(call BuildPackage,nut))
$(eval $(call BuildPackage,nut-web-cgi))
$(eval $(call BuildPackage,nut-avahi-service))
$(foreach d,$(filter-out $(SERIAL_DRIVERLIST_IGNORE),$(SERIAL_DRIVERLIST)),$(eval $(call BuildPackage,nut-driver-$(d))))
$(foreach d,$(SNMP_DRIVERLIST),$(eval $(call BuildPackage,nut-driver-$(d))))
$(foreach d,$(USB_LIBUSB_DRIVERLIST),$(eval $(call BuildPackage,nut-driver-$(d))))
