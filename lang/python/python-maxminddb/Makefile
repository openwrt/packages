#
# Copyright (C) 2019-2020 CZ.NIC z.s.p.o. (http://www.nic.cz/)
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-maxminddb
PKG_VERSION:=3.1.1
PKG_RELEASE:=1

PYPI_NAME:=maxminddb
PKG_HASH:=b19a938c481518f19a2c534ffdcb3bc59582f0fbbdcf9f81ac9adf912a0af686

PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-maxminddb
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Reader for the MaxMind DB format
  URL:=https://www.maxmind.com/
  DEPENDS:=+python3-light +python3-urllib +libmaxminddb
endef

define Package/python3-maxminddb/description
  Module for reading MaxMind DB files
endef

$(eval $(call Py3Package,python3-maxminddb))
$(eval $(call BuildPackage,python3-maxminddb))
$(eval $(call BuildPackage,python3-maxminddb-src))
