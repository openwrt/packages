#
# Copyright (C) 2013 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=accel-ppp
PKG_RELEASE:=2
PKG_VERSION:=1.12.0

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/xebd/accel-ppp.git
PKG_SOURCE_VERSION:=38b6104538522caf140796982e79db334aecaa08

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk
include $(INCLUDE_DIR)/kernel.mk

define Package/accel-ppp
  SECTION:=ne
  CATEGORY:=Network
  TITLE:=a High performance PPTP/L2TP/PPPoE/IPoE server for Linux
  URL:=http://accel-ppp.org/
  DEPENDS:=+libpcre +libopenssl +libtriton +kmod-nft-connlimit
endef

define Package/accel-ppp/config
	config DISABLE_RADIUS
		bool "Disable radius"
		depends on PACKAGE_accel-ppp
endef

define Package/accel-ppp/description
	The ACCEL-PPP v1.0 is completly new implementation of PPTP/PPPoE/L2TP/SSTP which was written from scratch.
Userspace daemon has its own PPP implementation, so it does not uses pppd and one process (multi-threaded) manages all connections.
ACCEL-PPP uses kernel-mode implementations of pptp/l2tp/pppoe and user-mode of sstp.
endef

define Package/libtriton
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=libtriton
  MENU:=1
endef

define KernelPackage/accel-pptp
	SECTION:=kernel
	CATEGORY:=Kernel modules
	SUBMENU:=Network Support
	TITLE:=pptp driver
	FILES:=$(PKG_BUILD_DIR)/build/drivers/pptp/driver/pptp.ko
	AUTOLOAD:=$(call AutoLoad,30, pptp)
	DEPENDS:=accel-ppp
endef

define KernelPackage/ipoe
	SECTION:=kernel
	CATEGORY:=Kernel modules
	SUBMENU:=Network Support
	TITLE:=ipoe driver
	FILES:=$(PKG_BUILD_DIR)/build/drivers/ipoe/driver/ipoe.ko
	AUTOLOAD:=$(call AutoLoad,30,ipoe)
	DEPENDS:=accel-ppp
endef

define KernelPackage/vlan-mon
	SECTION:=kernel
	CATEGORY:=Kernel modules
	SUBMENU:=Network Support
	TITLE:=vlan mon driver
	FILES:=$(PKG_BUILD_DIR)/build/drivers/vlan_mon/driver/vlan_mon.ko
	AUTOLOAD:=$(call AutoLoad,30,vlan_mon)
	DEPENDS:=accel-ppp
endef

CMAKE_BINARY_SUBDIR:=build

ifeq ($(CONFIG_PACKAGE_kmod-accel-pptp),y)
CMAKE_OPTIONS+=-DBUILD_PPTP_DRIVER=TRUE
endif

ifeq ($(CONFIG_PACKAGE_kmod-ipoe),y)
CMAKE_OPTIONS+=-DBUILD_IPOE_DRIVER=TRUE
endif

ifeq ($(CONFIG_PACKAGE_kmod-vlan-mon),y)
CMAKE_OPTIONS+=-DBUILD_VLAN_MON_DRIVER=TRUE
endif

ifeq ($(CONFIG_DISABLE_RADIUS),y)
CMAKE_OPTIONS+=-DRADIUS=FALSE
endif

CMAKE_OPTIONS+=-DKDIR=$(LINUX_DIR)

define Build/Prepare
	mkdir $(PKG_BUILD_DIR)/build
	$(call Build/Prepare/Default)
endef

define Package/libtriton/install
	$(INSTALL_DIR) $(1)/lib/
	$(CP) $(PKG_BUILD_DIR)/build/accel-pppd/triton/libtriton.so $(1)/lib/
endef

define Package/accel-ppp/install
	$(INSTALL_DIR) $(1)/etc $(1)/usr/bin $(1)/usr/lib/accel-ppp $(1)/lib
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/build/accel-cmd/accel-cmd $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/build/accel-pppd/accel-pppd $(1)/usr/bin/
	$(INSTALL_CONF) ./files/accel-ppp.conf $(1)/etc/
	$(CP) $(PKG_BUILD_DIR)/build/accel-pppd/extra/libippool.so $(1)/usr/lib/accel-ppp/
	$(CP) $(PKG_BUILD_DIR)/build/accel-pppd/extra/libconnlimit.so $(1)/usr/lib/accel-ppp/
	$(CP) $(PKG_BUILD_DIR)/build/accel-pppd/extra/libpppd_compat.so $(1)/usr/lib/accel-ppp/
	$(CP) $(PKG_BUILD_DIR)/build/accel-pppd/extra/libsigchld.so $(1)/lib/
	$(CP) $(PKG_BUILD_DIR)/build/accel-pppd/ctrl/pppoe/*.so $(1)/usr/lib/accel-ppp/
	$(CP) $(PKG_BUILD_DIR)/build/accel-pppd/ctrl/pptp/*.so $(1)/usr/lib/accel-ppp/
	$(CP) $(PKG_BUILD_DIR)/build/accel-pppd/ctrl/sstp/*.so $(1)/usr/lib/accel-ppp/
	$(CP) $(PKG_BUILD_DIR)/build/accel-pppd/ctrl/l2tp/*.so $(1)/usr/lib/accel-ppp/
	$(CP) $(PKG_BUILD_DIR)/build/accel-pppd/ctrl/ipoe/*.so $(1)/usr/lib/accel-ppp/
	$(CP) $(PKG_BUILD_DIR)/build/accel-pppd/vlan-mon/*.so $(1)/lib/
	$(CP) $(PKG_BUILD_DIR)/build/accel-pppd/shaper/*.so $(1)/usr/lib/accel-ppp/
	$(CP) $(PKG_BUILD_DIR)/build/accel-pppd/auth/*.so $(1)/usr/lib/accel-ppp/
	$(CP) $(PKG_BUILD_DIR)/build/accel-pppd/radius/*.so $(1)/usr/lib/accel-ppp/
	$(CP) $(PKG_BUILD_DIR)/build/accel-pppd/ipv6/*.so $(1)/usr/lib/accel-ppp/
	$(CP) $(PKG_BUILD_DIR)/build/accel-pppd/logs/*.so $(1)/usr/lib/accel-ppp/
endef

$(eval $(call BuildPackage,accel-ppp))
$(eval $(call BuildPackage,libtriton))
$(eval $(call KernelPackage,accel-pptp))
$(eval $(call KernelPackage,ipoe))
$(eval $(call KernelPackage,vlan-mon))
