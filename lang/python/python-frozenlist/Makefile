#
# Copyright (C) 2023 Jeffery To
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-frozenlist
PKG_VERSION:=1.4.0
PKG_RELEASE:=1

PYPI_NAME:=frozenlist
PKG_HASH:=09163bdf0b2907454042edb19f887c6d33806adc71fbd54afc14908bfdc22251

PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Jeffery To <jeffery.to@gmail.com>

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-frozenlist
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=List-like structure
  URL:=https://github.com/aio-libs/frozenlist
  DEPENDS:=+python3-light
endef

define Package/python3-frozenlist/description
frozenlist.FrozenList is a list-like structure which implements
collections.abc.MutableSequence. The list is mutable until
FrozenList.freeze is called, after which list modifications raise
RuntimeError.
endef

$(eval $(call Py3Package,python3-frozenlist))
$(eval $(call BuildPackage,python3-frozenlist))
$(eval $(call BuildPackage,python3-frozenlist-src))
