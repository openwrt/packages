#
# Copyright (C) 2022 Julien Malik <julien.malik@paraiso.me>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-sortedcontainers
PKG_VERSION:=2.4.0
PKG_RELEASE:=1

PYPI_NAME:=sortedcontainers
PKG_HASH:=25caa5a06cc30b6b83d11423433f65d1f9d76c4c6a0c90e3379eaa43b9bfdb88

PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Julien Malik <julien.malik@paraiso.me>

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-sortedcontainers
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Sorted Containers -- Sorted List, Sorted Dict, Sorted Set
  URL:=https://grantjenks.com/docs/sortedcontainers
  DEPENDS:=+python3-light
endef

define Package/python3-sortedcontainers/description
  Sorted Containers is an Apache2 licensed sorted collections library, written in pure-Python, and fast as C-extensions.
endef

$(eval $(call Py3Package,python3-sortedcontainers))
$(eval $(call BuildPackage,python3-sortedcontainers))
$(eval $(call BuildPackage,python3-sortedcontainers-src))
