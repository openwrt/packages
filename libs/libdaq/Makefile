#
# Copyright (C) 2012-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libdaq
PKG_VERSION:=2.0.4
PKG_RELEASE:=2

PKG_SOURCE_URL:=https://www.snort.org/downloads/snort/ \
	@SF/snort
PKG_SOURCE:=daq-$(PKG_VERSION).tar.gz
PKG_MD5SUM:=65e51d72e9d5d8b397e192e4e5857eff
PKG_BUILD_DIR:=$(BUILD_DIR)/daq-$(PKG_VERSION)

PKG_LICENSE:=GPL-2.0
PKG_MAINTAINER:=Luka Perkov <luka@openwrt.org>

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk

define Package/libdaq
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=DAQ library
  URL:=$(PKG_SOURCE_URL)
  DEPENDS:=+libdnet +libpcap
endef

define Package/libdaq/description
 Data Acquisition library for packet I/O.
endef

CONFIGURE_ARGS+= \
	--disable-static \
	--disable-nfq-module \
	--with-dnet-includes="$(STAGING_DIR)/usr/include" \
	--with-dnet-libraries="$(STAGING_DIR)/usr/lib" \
	--with-libpcap-includes="$(STAGING_DIR)/usr/include" \
	--with-libpcap-libraries="$(STAGING_DIR)/usr/lib" \

define Build/Compile
	$(MAKE) $(MAKE_FLAGS) -C $(PKG_BUILD_DIR)
endef

define Build/Install
	$(MAKE) $(MAKE_FLAGS) -C $(PKG_BUILD_DIR) install DESTDIR=$(PKG_INSTALL_DIR)
endef

define Build/InstallDev
	$(INSTALL_DIR) $(STAGING_DIR)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/*.h $(STAGING_DIR)/usr/include/
	$(INSTALL_DIR) $(STAGING_DIR)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/lib* $(STAGING_DIR)/usr/lib/
	$(INSTALL_DIR) $(STAGING_DIR)/usr/lib/daq
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/daq/* $(STAGING_DIR)/usr/lib/daq/
	$(INSTALL_DIR) $(STAGING_DIR)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/daq-modules-config $(STAGING_DIR)/usr/bin/
endef

define Package/libdaq/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/*.so* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/daq
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/daq/*.so* $(1)/usr/lib/daq/
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/daq-modules-config $(1)/usr/bin/
endef

$(eval $(call BuildPackage,libdaq))
