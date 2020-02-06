#
# Copyright (C) 2019 CZ.NIC, z. s. p. o. (https://www.nic.cz/)
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-atomicwrites
PKG_VERSION:=1.3.0
PKG_RELEASE:=1

PYPI_NAME:=atomicwrites
PKG_HASH:=75a9445bac02d8d058d5e1fe689654ba5a6556a1dfd8ce6ec55a0ed79866cfa6

PKG_MAINTAINER:=Jan Pavlinec <jan.pavlinec@nic.cz>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-atomicwrites
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Atomic file writes
  URL:=https://github.com/untitaker/python-atomicwrites
  DEPENDS:=+python3-light
  VARIANT:=python3
endef

define Package/python3-atomicwrites/description
  Python library for atomic file writes.
endef

$(eval $(call Py3Package,python3-atomicwrites))
$(eval $(call BuildPackage,python3-atomicwrites))
$(eval $(call BuildPackage,python3-atomicwrites-src))
