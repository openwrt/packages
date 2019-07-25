#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-egenix-mx-base
PKG_VERSION:=3.2.9
PKG_RELEASE:=4

PKG_SOURCE:=egenix-mx-base-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://downloads.egenix.com/python
PKG_HASH:=1c6b67688e7a231c6c1da09b7a6a2210745c3f2507bdda70e2639faedbf68977
PKG_BUILD_DIR:=$(BUILD_DIR)/egenix-mx-base-$(PKG_VERSION)

PKG_MAINTAINER:=Dmitry Trefilov <the-alien@live.ru>
PKG_LICENSE:=eGenix
PKG_LICENSE_FILES:=LICENSE COPYRIGHT

include $(INCLUDE_DIR)/package.mk
include ../python-package.mk

define Package/python-egenix-mx-base
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Egenix mxBase
  SUBMENU:=Python
  URL:=https://www.egenix.com/products/python/mxBase/
  DEPENDS:=+python-light
  VARIANT:=python
endef

define Package/python-egenix-mx-base/description
 The eGenix.com mx Base Distribution for Python is a collection
 of professional quality software tools which enhance Python's
 usability in many important areas such as fast text searching,
 date/time processing and high speed data types.
endef

PYTHON_PKG_SETUP_ARGS:=

$(eval $(call PyPackage,python-egenix-mx-base))
$(eval $(call BuildPackage,python-egenix-mx-base))
$(eval $(call BuildPackage,python-egenix-mx-base-src))
