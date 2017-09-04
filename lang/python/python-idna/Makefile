#
# Copyright (C) 2015-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-idna
PKG_VERSION:=2.5
PKG_RELEASE:=1

PKG_SOURCE:=idna-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://pypi.python.org/packages/d8/82/28a51052215014efc07feac7330ed758702fc0581347098a81699b5281cb
PKG_HASH:=3cb5ce08046c4e3a560fc02f138d0ac63e00f8ce5901a56b32ec8b7994082aab

PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE.rst
PKG_MAINTAINER:=Jeffery To <jeffery.to@gmail.com>, Alexandru Ardelean <ardeleanalex@gmail.com>

PKG_BUILD_DIR:=$(BUILD_DIR)/$(BUILD_VARIANT)-idna-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
$(call include_mk, python-package.mk)
$(call include_mk, python3-package.mk)

PKG_UNPACK:=$(HOST_TAR) -C $(PKG_BUILD_DIR) --strip-components=1 -xzf $(DL_DIR)/$(PKG_SOURCE)

define Package/python-idna/Default
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  URL:=https://github.com/kjd/idna
endef

define Package/python-idna
$(call Package/python-idna/Default)
  TITLE:=python-idna
  DEPENDS:=+PACKAGE_python-idna:python-light
  VARIANT:=python
endef

define Package/python3-idna
$(call Package/python-idna/Default)
  TITLE:=python3-idna
  DEPENDS:=+PACKAGE_python3-idna:python3-light
  VARIANT:=python3
endef

define Package/python-idna/description
A library to support the Internationalised Domain Names in Applications
(IDNA) protocol as specified in RFC 5891. This version of the protocol
is often referred to as "IDNA2008" and can produce different results
from the earlier standard from 2003.
endef

define Package/python3-idna/description
$(call define Package/python-idna/description)
.
(Variant for Python3)
endef

$(eval $(call PyPackage,python-idna))
$(eval $(call BuildPackage,python-idna))
$(eval $(call Py3Package,python3-idna))
$(eval $(call BuildPackage,python3-idna))
