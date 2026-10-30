#
# Copyright (C) 2021 CZ.NIC, z. s. p. o. (https://www.nic.cz/)
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-bidict
PKG_VERSION:=0.24.1
PKG_RELEASE:=1

PYPI_NAME:=bidict
PKG_HASH:=4dca6c17f0b01700e9f24359daa5ebabf7be022d99f4cb2a257b6af2a5076c88

PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>
PKG_LICENSE:=MPL-2.0
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=python-setuptools/host

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-bidict
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Bidirectional mapping library
  URL:=https://bidict.readthedocs.io/
  DEPENDS:= \
	+python3-light
endef

define Package/python3-bidict/description
  The bidirectional mapping library for Python.
endef

$(eval $(call Py3Package,python3-bidict))
$(eval $(call BuildPackage,python3-bidict))
$(eval $(call BuildPackage,python3-bidict-src))
