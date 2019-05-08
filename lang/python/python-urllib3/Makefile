#
# Copyright (C) 2007-2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-urllib3
PKG_VERSION:=1.24.3
PKG_RELEASE:=1

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE.txt

PKG_SOURCE:=urllib3-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/source/u/urllib3
PKG_HASH:=2393a695cd12afedd0dcb26fe5d50d0cf248e5a66f75dbd89a3d4eb333a61af4

PKG_BUILD_DIR:=$(BUILD_DIR)/urllib3-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include ../python-package.mk

define Package/python-urllib3
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Sanity-friendly HTTP client
  URL:=https://urllib3.readthedocs.io/
  DEPENDS:=+python
  VARIANT:=python
endef

define Package/python-urllib3/description
  HTTP library with thread-safe connection pooling, file post, and more.
endef

$(eval $(call PyPackage,python-urllib3))
$(eval $(call BuildPackage,python-urllib3))
$(eval $(call BuildPackage,python-urllib3-src))
