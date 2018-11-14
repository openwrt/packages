#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python3-bottle
PKG_VERSION:=0.12.13
PKG_RELEASE:=1

PKG_LICENSE:=MIT
PKG_MAINTAINER:=Luka Perkov <luka@openwrt.org>

PKG_SOURCE:=bottle-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/source/b/bottle
PKG_HASH:=39b751aee0b167be8dffb63ca81b735bbf1dd0905b3bc42761efedee8f123355
PKG_BUILD_DIR:=$(BUILD_DIR)/bottle-$(PKG_VERSION)
PKG_UNPACK=$(HOST_TAR) -C $(PKG_BUILD_DIR) --strip-components=1 -xzf $(DL_DIR)/$(PKG_SOURCE)

include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-bottle
	SECTION:=lang
	CATEGORY:=Languages
	SUBMENU:=Python
	TITLE:=Bottle is a fast, simple and lightweight WSGI micro web-framework for Python
	URL:=https://bottlepy.org
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
