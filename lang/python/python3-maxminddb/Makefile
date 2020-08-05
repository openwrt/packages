#
# Copyright (C) 2019-2020 CZ.NIC z.s.p.o. (http://www.nic.cz/)
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
#

include $(TOPDIR)/rules.mk

PKG_NAME:=maxminddb
PKG_VERSION:=2.0.2
PKG_RELEASE:=1

PYPI_NAME:=$(PKG_NAME)
PKG_HASH:=b95d8ed21799e6604683669c7ed3c6a184fcd92434d5762dccdb139b4f29e597

PKG_MAINTAINER:=Jan Pavlinec <jan.pavlinec@nic.cz>
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
  URL:=https://dev.maxmind.com/
  DEPENDS:=+python3-light +libmaxminddb
endef

define Package/python3-maxminddb/description
  Module for reading MaxMind DB files
endef

$(eval $(call Py3Package,python3-maxminddb))
$(eval $(call BuildPackage,python3-maxminddb))
$(eval $(call BuildPackage,python3-maxminddb-src))
