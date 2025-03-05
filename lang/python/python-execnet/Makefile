#
# Copyright (C) 2020-2021 CZ.NIC, z. s. p. o. (https://www.nic.cz/)
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-execnet
PKG_VERSION:=2.0.2
PKG_RELEASE:=1

PYPI_NAME:=execnet
PKG_HASH:=cc59bc4423742fd71ad227122eb0dd44db51efb3dc4095b45ac9a08c770096af

PKG_MAINTAINER:=Jan Pavlinec <jan.pavlinec1@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=python-hatchling/host python-hatch-vcs/host

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-execnet
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Rapid multi-Python deployment
  URL:=https://execnet.readthedocs.io
  DEPENDS:=+python3-light
endef

define Package/python3-execnet/description
execnet provides carefully tested means to ad-hoc interact with Python
interpreters across version, platform and network barriers.
endef

$(eval $(call Py3Package,python3-execnet))
$(eval $(call BuildPackage,python3-execnet))
$(eval $(call BuildPackage,python3-execnet-src))
