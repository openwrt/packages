#
# Copyright (C) 2019 CZ.NIC, z. s. p. o. (https://www.nic.cz/)
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-pyrsistent
PKG_VERSION:=0.15.3
PKG_RELEASE:=1

PKG_SOURCE:=pyrsistent-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/source/p/pyrsistent/
PKG_HASH:=50cffebc87ca91b9d4be2dcc2e479272bcb466b5a0487b6c271f7ddea6917e14
PKG_BUILD_DIR:=$(BUILD_DIR)/pyrsistent-$(PKG_VERSION)

PKG_MAINTAINER:=Josef Schlehofer <josef.schlehofer@nic.cz>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE.mit

include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-pyrsistent
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Persistent/Functional/Immutable data structures
  URL:=https://github.com/tobgu/pyrsistent
  DEPENDS:=+python3-light +python3-six
  VARIANT:=python3
endef

define Package/python3-pyrsistent/description
  Pyrsistent is a number of persistent collections (by some referred to as functional data structures).
  Persistent in the sense that they are immutable.
endef

$(eval $(call Py3Package,python3-pyrsistent))
$(eval $(call BuildPackage,python3-pyrsistent))
$(eval $(call BuildPackage,python3-pyrsistent-src))
