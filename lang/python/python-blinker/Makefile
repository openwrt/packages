#
# Copyright (C) 2025 Alexandru Ardelean <ardeleanalex@gmail.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-blinker
PKG_VERSION:=1.9.0
PKG_RELEASE:=1

PYPI_NAME:=blinker
PKG_HASH:=b4ce2265a7abece45e7cc896e98dbebe6cead56bcf805a3d23136d145f5445bf

PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE.txt

PKG_BUILD_DEPENDS:=python-flit-core/host

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-blinker
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Fast, simple object-to-object and broadcast signaling
  URL:=https://blinker.readthedocs.io/
  DEPENDS:=+python3-light
endef

define Package/python3-blinker/description
Blinker provides fast, simple object-to-object and broadcast signaling
for Python objects. It is used by Flask to implement its signal system.
endef

$(eval $(call Py3Package,python3-blinker))
$(eval $(call BuildPackage,python3-blinker))
$(eval $(call BuildPackage,python3-blinker-src))
