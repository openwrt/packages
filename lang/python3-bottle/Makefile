#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python3-bottle
PKG_VERSION:=0.12.8
PKG_RELEASE:=1

PKG_LICENSE:=MIT
PKG_MAINTAINER:=Luka Perkov <luka@openwrt.org>

PKG_SOURCE:=$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/bottlepy/bottle/archive
PKG_MD5SUM:=50a6ebada59391e8d01b2bd2ec52f05b
PKG_BUILD_DIR:=$(BUILD_DIR)/bottle-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
$(call include_mk, python3-package.mk)

define Package/python3-bottle
	SECTION:=lang
	CATEGORY:=Languages
	SUBMENU:=Python
	TITLE:=Bottle is a fast, simple and lightweight WSGI micro web-framework for Python
	URL:=http://bottlepy.org
	DEPENDS:=+python3
endef

define Package/python3-bottle/description
 Bottle is a fast, simple and lightweight WSGI micro web-framework for Python.
 It is distributed as a single file module and has no dependencies other than the
 Python Standard Library.
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/python3-bottle/install
	$(INSTALL_DIR) $(1)$(PYTHON3_PKG_DIR)
	$(CP) $(PKG_BUILD_DIR)/bottle.py $(1)$(PYTHON3_PKG_DIR)
endef

$(eval $(call BuildPackage,python3-bottle))
