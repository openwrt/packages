#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python3-bottle
PKG_VERSION:=0.12.17
PKG_RELEASE:=1

PKG_SOURCE:=bottle-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/source/b/bottle
PKG_HASH:=e9eaa412a60cc3d42ceb42f58d15864d9ed1b92e9d630b8130c871c5bb16107c
PKG_BUILD_DIR:=$(BUILD_DIR)/bottle-$(PKG_VERSION)

PKG_MAINTAINER:=Josef Schlehofer <josef.schlehofer@nic.cz>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_CPE_ID:=cpe:/a:bottlepy:bottle

include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-bottle
	SECTION:=lang
	CATEGORY:=Languages
	SUBMENU:=Python
	TITLE:=Fast and simple WSGI-framework for small web-applications
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
