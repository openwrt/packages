#
# Copyright (C) 2015-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=linuxptp
PKG_VERSION:=4.4
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tgz
PKG_SOURCE_URL:=https://downloads.nwtime.org/linuxptp/
PKG_HASH:=61757bc0a58d789b8fcbdddf56c88a0230597184a70dcb2ac05b4c6b619f7d5c

PKG_MAINTAINER:=Wojciech Dubowik <Wojciech.Dubowik@westermo.com>
PKG_LICENSE:=GPL-2.0-only
PKG_LICENSE_FILES:=COPYING
PKG_CPE_ID:=cpe:/a:linuxptp_project:linuxptp

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/kernel.mk

define Package/linuxptp
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Time Synchronization
  TITLE:=Linux Precision Time Protocol (PTP) daemon
  URL:=https://linuxptp.nwtime.org/
endef

define Package/linuxptp/description
 The PTP daemon (PTPd) implements version 2 of the Precision Time Protocol (PTP)
 as defined by the IEEE 1588-2008 standard.
 PTP was developed to provide very precise time coordination of LAN connected
 computers.
endef

define Package/linuxptp/conffiles
/etc/config/linuxptp
endef

EXTRA_CFLAGS += -DHAVE_CLOCK_ADJTIME -DHAVE_POSIX_SPAWN -DHAVE_ONESTEP_SYNC

MAKE_VARS += \
	EXTRA_CFLAGS="$(TARGET_CFLAGS) $(TARGET_CPPFLAGS) $(EXTRA_CFLAGS)" \
	KBUILD_OUTPUT="$(LINUX_DIR)" \
	NO_AUTODETECT_SAD_MAC_LIB="y"

# separate compile step for helper utility
define Build/Compile/sysclock-discipline-check
	$(TARGET_CC) $(TARGET_CFLAGS) -o $(PKG_BUILD_DIR)/sysclock-discipline-check $(CURDIR)/files/sysclock-discipline-check.c $(TARGET_LDFLAGS)
endef

# override/extend the default Build/Compile
define Build/Compile
	$(call Build/Compile/Default)
	$(call Build/Compile/sysclock-discipline-check)
endef

define Package/linuxptp/install
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DATA) $(CURDIR)/files/linuxptp.config $(1)/etc/config/linuxptp
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) $(CURDIR)/files/phc2sys.init $(1)/etc/init.d/phc2sys
	$(INSTALL_BIN) $(CURDIR)/files/ptp4l.init $(1)/etc/init.d/ptp4l
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/sysclock-discipline-check $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/hwstamp_ctl $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/phc2sys $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/phc_ctl $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/pmc $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ptp4l $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/timemaster $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,linuxptp))
