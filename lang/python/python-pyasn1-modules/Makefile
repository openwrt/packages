#
# Copyright (C) 2015-2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-pyasn1-modules
PKG_VERSION:=0.0.11
PKG_RELEASE:=1

PKG_SOURCE:=pyasn1-modules-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://pypi.python.org/packages/de/5f/0c6a1a096bfc2831ee8e2e951f79e6ec23c853c17ab5ba655322bfcde20a
PKG_HASH:=60d5c80bfee9b79b492d5d8a934b3ecfc523f2f83aaab4ffafa2bbb651d3c67a

PKG_LICENSE:=BSD-2-Clause
PKG_LICENSE_FILES:=LICENSE.txt
PKG_MAINTAINER:=Jeffery To <jeffery.to@gmail.com>, Alexandru Ardelean <ardeleanalex@gmail.com>

PKG_BUILD_DIR:=$(BUILD_DIR)/$(BUILD_VARIANT)-pyasn1-modules-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
$(call include_mk, python-package.mk)
$(call include_mk, python3-package.mk)

PKG_UNPACK:=$(HOST_TAR) -C $(PKG_BUILD_DIR) --strip-components=1 -xzf $(DL_DIR)/$(PKG_SOURCE)

define Package/python-pyasn1-modules/Default
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  URL:=http://sourceforge.net/projects/pyasn1/
endef

define Package/python-pyasn1-modules
$(call Package/python-pyasn1-modules/Default)
  TITLE:=python-pyasn1-modules
  VARIANT:=python
  DEPENDS:= \
      +PACKAGE_python-pyasn1-modules:python-light \
      +PACKAGE_python-pyasn1-modules:python-pyasn1
endef

define Package/python3-pyasn1-modules
$(call Package/python-pyasn1-modules/Default)
  TITLE:=python3-pyasn1-modules
  VARIANT:=python3
  DEPENDS:= \
      +PACKAGE_python3-pyasn1-modules:python3-light \
      +PACKAGE_python3-pyasn1-modules:python3-pyasn1
endef

define Package/python-pyasn1-modules/description
This is a small but growing collection of ASN.1 data structures
expressed in Python terms using pyasn1 data model.
endef

define Package/python3-pyasn1-modules/description
$(call Package/python-pyasn1-modules/description)
.
(Variant for Python3).
endef

$(eval $(call PyPackage,python-pyasn1-modules))
$(eval $(call BuildPackage,python-pyasn1-modules))
$(eval $(call Py3Package,python3-pyasn1-modules))
$(eval $(call BuildPackage,python3-pyasn1-modules))
