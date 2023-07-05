#
# Copyright (C) Alexandru Ardelean <ardeleanalex@gmail.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=pymysql
PKG_VERSION:=1.1.0
PKG_RELEASE:=1

PYPI_NAME:=PyMySQL
PKG_HASH:=4f13a7df8bf36a51e81dd9f3605fede45a4878fe02f9236349fd82a3f0612f96

PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

PKG_CONFIG_DEPENDS:=CONFIG_PYTHON3_PYMYSQL_SHA_PASSWORD_SUPPORT

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-pymysql
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Pure Python MySQL Client
  URL:=https://pymysql.readthedocs.io/
  DEPENDS:=+python3 +PYTHON3_PYMYSQL_SHA_PASSWORD_SUPPORT:python3-cryptography
endef

define Package/python3-pymysql/config
  source "$(SOURCE)/Config.in"
endef

define Package/python3-pymysql/description
  This package contains a pure-Python MySQL client library, based on PEP 249.
endef

$(eval $(call Py3Package,python3-pymysql))
$(eval $(call BuildPackage,python3-pymysql))
$(eval $(call BuildPackage,python3-pymysql-src))
