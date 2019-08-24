#
# Copyright (C) 2019 Moddable Tech, Inc.
#
# This is free software, licensed under the GNU General Public License v3 or later.
# See /licenses for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libxs

PKG_SOURCE_URL:=https://github.com/Moddable-OpenSource/moddable.git
PKG_SOURCE_PROTO:=git
PKG_SOURCE_DATE:=2019-08-14
PKG_SOURCE_VERSION:=d53090efd417f08d521ad81d4f68169058dff4b6
PKG_MIRROR_HASH:=9da42794b73fb186a448b994d44a3daaeba18bbdf973eb84547ad87e36a7d79f

PKG_MAINTAINER:=Brian Friedkin <brian@moddable.tech>
PKG_LICENSE:=GPL-3.0-or-later LGPL-3.0-or-later
PKG_LICENSE_FILES:=licenses/NOTICE licenses/gpl-3.0.txt licenses/lgpl-3.0.txt

DEBUG?=1
INSTRUMENT?=1

include $(INCLUDE_DIR)/package.mk

define Package/libxs
	SECTION:=libraries
	CATEGORY:=Libraries
	TITLE:=Moddable SDK XS JavaScript Engine Library
	URL:=https://www.moddable.com/
endef

define Package/libxs/description
Use this package to build the XS JavaScript engine library 

XS is the JavaScript engine at the core of Moddable applications and tools
endef

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR)/build/devices/openwrt/targets -f make.libxs.mk \
		CC="$(TARGET_CC)" CFLAGS="$(TARGET_CFLAGS)" LDFLAGS="$(TARGET_LDFLAGS)" \
		DEBUG=$(DEBUG) INSTRUMENT=$(INSTRUMENT) PKG_BUILD_DIR=$(PKG_BUILD_DIR) MODDABLE=$(PKG_BUILD_DIR)
endef

define Package/libxs/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/libxs.so $(1)/usr/lib
endef

$(eval $(call BuildPackage,libxs))

