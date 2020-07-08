#
# Copyright (C) 2019 CZ.NIC z.s.p.o. (http://www.nic.cz/)
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
#

include $(TOPDIR)/rules.mk

PKG_NAME:=maxminddb
PKG_VERSION:=1.4.1
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/source/m/maxminddb/
PKG_HASH:=df1451bcd848199905ac0de4631b3d02d6a655ad28ba5e5a4ca29a23358db712

PKG_MAINTAINER:=Jan Pavlinec <jan.pavlinec@nic.cz>
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-maxminddb
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Reader for the MaxMind DB format
  URL:=https://dev.maxmind.com/
  DEPENDS:=+python3-light +libmaxminddb
  VARIANT:=python3
endef

define Package/python3-maxminddb/description
  Module for reading MaxMind DB files
endef

$(eval $(call Py3Package,python3-maxminddb))
$(eval $(call BuildPackage,python3-maxminddb))
$(eval $(call BuildPackage,python3-maxminddb-src))
