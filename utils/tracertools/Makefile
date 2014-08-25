#
# Copyright (C) 2007-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=tracertools
PKG_VERSION:=0.1
PKG_RELEASE=$(PKG_SOURCE_VERSION)
PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>

PKG_LICENSE:=GPL-3.0

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://gitorious.org/tracertools/tracertools.git
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=701691a5e206dca361f5b5e5bd2f508dd5b160cd
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz

PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/tracertools
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Tracer probing/fuzzing
endef

define Package/tracertools/description
	Tools for the Tracer MPPT solar charge controller.
endef

define Package/tracertools/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/reqdata $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/parsereply $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/fuzzreply $(1)/usr/bin/
endef

$(eval $(call BuildPackage,tracertools))
