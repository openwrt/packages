# SPDX-License-Identifier: GPL-2.0-only
#
# Copyright (C) 2026 Abdulkader Alrezej <alrazj.abdulkader@gmail.com>

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=accel-ppp
PKG_VERSION:=1.14.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/accel-ppp/accel-ppp/archive/refs/tags
PKG_SOURCE_URL_FILE:=$(PKG_VERSION).tar.gz
PKG_HASH:=9386c0b34ae9dd35e61c254980fd9f4e64c510f38fc97fe939b51625418f89f7

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

PKG_MAINTAINER:=Abdulkader Alrezej <alrazj.abdulkader@gmail.com>
PKG_LICENSE:=GPL-2.0-only
PKG_LICENSE_FILES:=COPYING

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

CMAKE_BINARY_SUBDIR:=openwrt-build

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

ATOMIC_ARCHS:=arm armeb mips mipsel powerpc x86_64

define Package/accel-ppp
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=VPN
  TITLE:=High-performance PPTP/L2TP/SSTP/PPPoE/IPoE server
  URL:=https://github.com/accel-ppp/accel-ppp
  DEPENDS:=\
	+libpcre2 \
	+libopenssl \
	+libpthread \
	+librt \
	+(arm||armeb||mips||mipsel||powerpc||x86_64):libatomic \
	+libucontext \
	+kmod-sched-core \
	+kmod-pptp \
	+kmod-pppoe \
	+kmod-ppp
endef

define Package/accel-ppp/description
  ACCEL-PPP is a high-performance PPTP, L2TP, SSTP, PPPoE and IPoE
  server for Linux.
endef

define KernelPackage/accel-ppp-ipoe
  SUBMENU:=Network Support
  TITLE:=ACCEL-PPP IPoE kernel module
  URL:=https://github.com/accel-ppp/accel-ppp
  FILES:=$(PKG_BUILD_DIR)/drivers/ipoe/ipoe.$(LINUX_KMOD_SUFFIX)
  AUTOLOAD:=$(call AutoProbe,ipoe)
endef

define KernelPackage/accel-ppp-ipoe/description
  Kernel module implementing the ACCEL-PPP IPoE virtual interface.
endef

define KernelPackage/accel-ppp-vlan-mon
  SUBMENU:=Network Support
  TITLE:=ACCEL-PPP VLAN monitor kernel module
  URL:=https://github.com/accel-ppp/accel-ppp
  FILES:=$(PKG_BUILD_DIR)/drivers/vlan_mon/vlan_mon.$(LINUX_KMOD_SUFFIX)
  AUTOLOAD:=$(call AutoProbe,vlan_mon)
endef

define KernelPackage/accel-ppp-vlan-mon/description
  Kernel module providing VLAN monitoring for ACCEL-PPP IPoE and PPPoE.
endef

define Package/accel-ppp/conffiles
/etc/accel-ppp/accel-ppp.conf
endef

CMAKE_OPTIONS += \
	-DBUILD_PPTP_DRIVER=FALSE \
	-DBUILD_IPOE_DRIVER=FALSE \
	-DBUILD_VLAN_MON_DRIVER=FALSE \
	-DCPACK_TYPE=OpenWrt \
	-DMUSL=$(if $(CONFIG_USE_MUSL),ON,OFF) \
	-DKDIR=$(LINUX_DIR) \
	-DCMAKE_INSTALL_PREFIX=/usr \
	-DCMAKE_INSTALL_LIBDIR=lib \
	-DCMAKE_INSTALL_SYSCONFDIR=/etc/accel-ppp \
	-DCMAKE_INSTALL_LOCALSTATEDIR=/var \
	-DCMAKE_BUILD_TYPE=Release \
	-DLOG_PGSQL=FALSE \
	-DLOG_FILE=TRUE \
	-DSHAPER=TRUE \
	-DRADIUS=TRUE \
	-DNETSNMP=FALSE \
	-DLUA=FALSE \
	-DLIB_SUFFIX=

TARGET_LDFLAGS += $(if $(filter $(ATOMIC_ARCHS),$(ARCH)),-latomic)

define Build/Compile
	$(call Build/Compile/Default)
	+$(if $(CONFIG_PACKAGE_kmod-accel-ppp-ipoe),$(KERNEL_MAKE) \
		M="$(PKG_BUILD_DIR)/drivers/ipoe" \
		ccflags-y="-I$(CMAKE_BINARY_DIR)" modules,true)
	+$(if $(CONFIG_PACKAGE_kmod-accel-ppp-vlan-mon),$(KERNEL_MAKE) \
		M="$(PKG_BUILD_DIR)/drivers/vlan_mon" \
		ccflags-y="-I$(CMAKE_BINARY_DIR)" modules,true)
endef

define Package/accel-ppp/install
	$(INSTALL_DIR) \
		$(1)/usr/sbin \
		$(1)/usr/bin \
		$(1)/usr/share/accel-ppp/radius \
		$(1)/usr/share/accel-ppp/l2tp \
		$(1)/usr/lib/accel-ppp \
		$(1)/etc/init.d \
		$(1)/etc/accel-ppp

	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/accel-pppd $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/accel-cmd $(1)/usr/bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/accel-ppp/*.so $(1)/usr/lib/accel-ppp/
	$(LN) accel-ppp/libtriton.so $(1)/usr/lib/libtriton.so
	$(LN) accel-ppp/libvlan-mon.so $(1)/usr/lib/libvlan-mon.so
	$(LN) accel-ppp/libconnlimit.so $(1)/usr/lib/libconnlimit.so
	$(LN) accel-ppp/libsigchld.so $(1)/usr/lib/libsigchld.so
	$(LN) accel-ppp/libippool.so $(1)/usr/lib/libippool.so
	$(LN) accel-ppp/libpppoe.so $(1)/usr/lib/libpppoe.so
	$(LN) accel-ppp/libradius.so $(1)/usr/lib/libradius.so
	$(LN) accel-ppp/libshaper.so $(1)/usr/lib/libshaper.so
	$(LN) accel-ppp/liblog_tcp.so $(1)/usr/lib/liblog_tcp.so
	$(LN) accel-ppp/liblogwtmp.so $(1)/usr/lib/liblogwtmp.so
	$(LN) accel-ppp/libpppd_compat.so $(1)/usr/lib/libpppd_compat.so
	$(LN) accel-ppp/libpptp.so $(1)/usr/lib/libpptp.so

	$(INSTALL_DATA) \
		$(PKG_INSTALL_DIR)/usr/share/accel-ppp/radius/dictionary* \
		$(1)/usr/share/accel-ppp/radius/
	$(INSTALL_DATA) \
		$(PKG_INSTALL_DIR)/usr/share/accel-ppp/l2tp/dictionary* \
		$(1)/usr/share/accel-ppp/l2tp/

	$(INSTALL_BIN) files/accel-ppp.init $(1)/etc/init.d/accel-ppp
	$(INSTALL_CONF) files/accel-ppp.conf $(1)/etc/accel-ppp/accel-ppp.conf
endef

$(eval $(call BuildPackage,accel-ppp))
$(eval $(call KernelPackage,accel-ppp-ipoe))
$(eval $(call KernelPackage,accel-ppp-vlan-mon))
