#
# Copyright (C) 2007-2018 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-mysqlclient
PKG_VERSION:=1.4.4
PKG_RELEASE:=1
PKG_LICENSE:=GPL-2.0

PKG_SOURCE:=mysqlclient-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/source/m/mysqlclient
PKG_HASH:=9c737cc55a5dc8dd3583a942d5a9b21be58d16f00f5fefca4e575e7d9682e98c
PKG_BUILD_DIR:=$(BUILD_DIR)/$(BUILD_VARIANT)-mysqlclient-$(PKG_VERSION)
PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>

include $(INCLUDE_DIR)/package.mk
include ../python-package.mk
include ../python3-package.mk
# python-mysqlclient needs iconv
include $(INCLUDE_DIR)/nls.mk

PKG_UNPACK:=$(HOST_TAR) -C $(PKG_BUILD_DIR) --strip-components=1 -xzf $(DL_DIR)/$(PKG_SOURCE)

define Package/python-mysqlclient/Default
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  URL:=https://mysqlclient.readthedocs.io/
endef

define Package/python-mysqlclient
  $(call Package/python-mysqlclient/Default)
  TITLE:=MySQL database adapter for Python
  DEPENDS:=+PACKAGE_python-mysqlclient:python +libmysqlclient
  VARIANT:=python
endef

define Package/python3-mysqlclient
  $(call Package/python-mysqlclient/Default)
  TITLE:=MySQL database adapter for Python3
  DEPENDS:=+PACKAGE_python3-mysqlclient:python3 +libmysqlclient
  VARIANT:=python3
endef

define Package/python-mysqlclient/description
 MySQLdb is an thread-compatible interface to the popular MySQL database
 server that provides the Python database API.
endef

define Package/python3-mysqlclient/description
$(call Package/python-mysqlclient/description)
.
(Variant for Python3)
endef

$(eval $(call PyPackage,python-mysqlclient))
$(eval $(call BuildPackage,python-mysqlclient))
$(eval $(call BuildPackage,python-mysqlclient-src))

$(eval $(call Py3Package,python3-mysqlclient))
$(eval $(call BuildPackage,python3-mysqlclient))
$(eval $(call BuildPackage,python3-mysqlclient-src))
