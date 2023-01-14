#
# Copyright (C) 2006-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=stress
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=1.0.5
PKG_SOURCE_URL:=https://github.com/resurrecting-open-source-projects/stress
PKG_MIRROR_HASH:=711e42ead6fd220a98821aae0cf024930785e439d3d0d50663fed1b2cd021bd1

PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>
PKG_LICENSE:=GPL-2.0-only
PKG_LICENSE_FILES:=COPYING

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/stress
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=stress is a simple stress utility
  URL:=
endef

define Package/stress/description
stress is a simple tool that imposes certain types of compute \ stress on
UNIX-like operating systems.
endef

define Package/stress/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/stress $(1)/usr/bin/
endef

$(eval $(call BuildPackage,stress))
