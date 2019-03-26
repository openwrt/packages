#
# Copyright (C) 2009-2012 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=dmapd
PKG_VERSION:=0.0.79
PKG_RELEASE:=1

PKG_MAINTAINER:=W. Michael Petullo <mike@flyn.org>

PKG_LICENSE:=GPLv2
PKG_LICENSE_FILES:=COPYING

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://www.flyn.org/projects/dmapd
PKG_HASH:=3edd9e31961751317d35c5d4b1f8c7f52b0d4968c8850fbb03da778c8fcb0ce0

PKG_FIXUP:=autoreconf
PKG_INSTALL:=2

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk

define Package/dmapd
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+libdmapsharing +libdb47 +vips +libgst1pbutils
  TITLE:= dmapd
  URL:=http://www.flyn.org/projects/dmapd/
  USERID:=dmapd=56:dmapd=56
endef

define Package/dmapd/decription
	Dmapd is a DMAP server
endef

define Package/dmapd/conffiles
/etc/dmapd.conf
endef

TARGET_LDFLAGS+=\
	-Wl,-rpath-link=$(STAGING_DIR)/usr/lib \

define Package/dmapd/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/distro/dmapd.conf $(1)/etc/
	$(INSTALL_BIN) ./files/dmapd.init $(1)/etc/init.d/dmapd
	$(INSTALL_DIR) $(1)/usr/lib/dmapd/$(PKG_VERSION)/modules
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/sbin/dmapd \
		$(1)/usr/sbin/
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/libdmapd.so* \
		$(1)/usr/lib/
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/dmapd/$(PKG_VERSION)/modules/*.so \
		$(1)/usr/lib/dmapd/$(PKG_VERSION)/modules/
endef

$(eval $(call BuildPackage,dmapd))
