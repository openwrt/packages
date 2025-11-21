#
# Copyright (C) 2010-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=hiredis
PKG_VERSION:=1.3.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/redis/hiredis/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=25cee4500f359cf5cad3b51ed62059aadfc0939b05150c1f19c7e2829123631c

PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=COPYING
PKG_CPE_ID:=cpe:/a:redis:hiredis
PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>

PKG_BUILD_PARALLEL:=1
CMAKE_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/libhiredis
	SECTION:=libs
	CATEGORY:=Libraries
	TITLE:=Minimalistic C client for Redis
	URL:=https://github.com/redis/hiredis
endef

define Package/libhiredis/description
	Hiredis is a minimalistic C client library for the Redis database.
endef

define Package/libhiredis/install
	$(INSTALL_DIR) $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libhiredis.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libhiredis))
