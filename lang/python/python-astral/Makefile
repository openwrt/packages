#
# Copyright (C) 2019 CZ.NIC, z. s. p. o. (https://www.nic.cz/)
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-astral
PKG_VERSION:=1.10.1
PKG_RELEASE:=1

PKG_SOURCE:=astral-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/source/a/astral/
PKG_HASH:=d2a67243c4503131c856cafb1b1276de52a86e5b8a1d507b7e08bee51cb67bf1

PKG_BUILD_DIR:=$(BUILD_DIR)/$(BUILD_VARIANT)-astral-$(PKG_VERSION)

PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Josef Schlehofer <josef.schlehofer@nic.cz>

include $(INCLUDE_DIR)/package.mk
include ../python-package.mk
include ../python3-package.mk

PKG_UNPACK:=$(HOST_TAR) -C $(PKG_BUILD_DIR) --strip-components=1 -xzf $(DL_DIR)/$(PKG_SOURCE)

define Package/python-astral/Default
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Calculations for the position of the sun and moon
  URL:=https://github.com/sffjunkie/astral
endef

define Package/python-astral
$(call Package/python-astral/Default)
  DEPENDS+= \
      +PACKAGE_python-astral:python-light \
      +PACKAGE_python-astral:python-pytz
  VARIANT:=python
endef

define Package/python3-astral
$(call Package/python-astral/Default)
  DEPENDS+= \
      +PACKAGE_python3-astral:python3-light \
      +PACKAGE_python3-astral:python3-pytz
  VARIANT:=python3
endef

define Package/python-astral/description
Astral is a python module for calculating the times of various aspects of the sun and moon.
endef

define Package/python3-astral/description
$(call Package/python-astral/description)
.
(Variant for Python3)
endef

$(eval $(call PyPackage,python-astral))
$(eval $(call BuildPackage,python-astral))
$(eval $(call BuildPackage,python-astral-src))

$(eval $(call Py3Package,python3-astral))
$(eval $(call BuildPackage,python3-astral))
$(eval $(call BuildPackage,python3-astral-src))
