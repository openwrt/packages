# 
# Copyright (C) 2010 segal.ubi.pt
# Copyright (C) 2014 nunojpg@gmail.com
# Copyright (C) 2015 dev@localnet.hu
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=open2300
PKG_VERSION:=1.12
PKG_RELEASE:=5
PKG_LICENSE:=GPL-2.0+
PKG_LICENSE_FILES:=COPYING

PKG_SOURCE_PROTO:=svn
PKG_SOURCE_URL:=http://www.lavrsen.dk/svn/open2300/trunk
PKG_SOURCE_VERSION:=r12
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.gz
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_CHECK_FORMAT_SECURITY:=0

PKG_MAINTAINER:=Gabor SZOLLOSI <dev@localnet.hu>

include $(INCLUDE_DIR)/package.mk

define Package/open2300
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=WS23XX weather station utilities
  URL:=http://www.lavrsen.dk/foswiki/bin/view/Open2300
endef

define Package/open2300/description
  This is an utility suite used to communicate with and collect data from a WS23XX wheather station.
endef

MAKE_FLAGS += \
	CFLAGS="$(TARGET_CFLAGS) -DVERSION=\"$(PKG_VERSION)\""

define Package/open2300/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin2300		$(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/cw2300		$(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/dump2300	$(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/fetch2300	$(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/histlog2300	$(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/history2300	$(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/interval2300	$(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/light2300	$(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/log2300		$(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/minmax2300	$(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/open2300	$(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/wu2300		$(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/xml2300		$(1)/usr/bin/

	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_DATA) ./files/open2300.conf $(1)/etc/

	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/lib2300.so.1.11 $(1)/usr/lib/
	ln -sf /usr/lib/lib2300.so.1.11 $(1)/usr/lib/lib2300.so
endef

$(eval $(call BuildPackage,open2300))
