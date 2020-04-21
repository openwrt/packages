#
# Copyright (C) 2007-2018 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-mysqlclient
PKG_VERSION:=1.4.6
PKG_RELEASE:=2
PKG_LICENSE:=GPL-2.0

PYPI_NAME:=mysqlclient
PKG_HASH:=f3fdaa9a38752a3b214a6fe79d7cae3653731a53e577821f9187e67cbecb2e16
PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk
# python-mysqlclient needs iconv
include $(INCLUDE_DIR)/nls.mk

define Package/python3-mysqlclient
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=MySQL database adapter
  URL:=https://mysqlclient.readthedocs.io/
  DEPENDS:=+python3 +libmysqlclient
endef

define Package/python3-mysqlclient/description
 MySQLdb is an thread-compatible interface to the popular MySQL database
 server that provides the Python database API.
endef

$(eval $(call Py3Package,python3-mysqlclient))
$(eval $(call BuildPackage,python3-mysqlclient))
$(eval $(call BuildPackage,python3-mysqlclient-src))
