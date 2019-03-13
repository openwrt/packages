#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python3-bottle
PKG_VERSION:=0.12.16
PKG_RELEASE:=1

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_CPE_ID:=cpe:/a:bottlepy:bottle

PKG_MAINTAINER:=Josef Schlehofer <josef.schlehofer@nic.cz>

PKG_SOURCE:=bottle-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/source/b/bottle
PKG_HASH:=9c310da61e7df2b6ac257d8a90811899ccb3a9743e77e947101072a2e3186726
PKG_BUILD_DIR:=$(BUILD_DIR)/$(BUILD_VARIANT)-bottle-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

PKG_UNPACK=$(HOST_TAR) -C $(PKG_BUILD_DIR) --strip-components=1 -xzf $(DL_DIR)/$(PKG_SOURCE)

define Package/python3-bottle
	SECTION:=lang
	CATEGORY:=Languages
	SUBMENU:=Python
	TITLE:=Bottle is a fast, simple and lightweight WSGI micro web-framework for Python
	URL:=https://bottlepy.org
	DEPENDS:=+python3
	VARIANT:=python3
endef

define Package/python3-bottle/description
 Bottle is a fast, simple and lightweight WSGI micro web-framework for Python.
 It is distributed as a single file module and has no dependencies other than the
 Python Standard Library.
endef

$(eval $(call Py3Package,python3-bottle))
$(eval $(call BuildPackage,python3-bottle))
$(eval $(call BuildPackage,python3-bottle-src))
