#
# Copyright (C) 2015-2018 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-pyasn1
PKG_VERSION:=0.4.2
PKG_RELEASE:=2

PKG_SOURCE:=pyasn1-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://pypi.python.org/packages/eb/3d/b7d0fdf4a882e26674c68c20f40682491377c4db1439870f5b6f862f76ed
PKG_HASH:=d258b0a71994f7770599835249cece1caef3c70def868c4915e6e5ca49b67d15

PKG_LICENSE:=BSD-2-Clause
PKG_LICENSE_FILES:=LICENSE.txt
PKG_MAINTAINER:=Jeffery To <jeffery.to@gmail.com>, Alexandru Ardelean <ardeleanalex@gmail.com>

PKG_BUILD_DIR:=$(BUILD_DIR)/$(BUILD_VARIANT)-pyasn1-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include ../python-package.mk
include ../python3-package.mk

PKG_UNPACK:=$(HOST_TAR) -C $(PKG_BUILD_DIR) --strip-components=1 -xzf $(DL_DIR)/$(PKG_SOURCE)

define Package/python-pyasn1/Default
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  URL:=http://pyasn1.sourceforge.net/
endef

define Package/python-pyasn1
$(call Package/python-pyasn1/Default)
  TITLE:=python-pyasn1
  DEPENDS:=+PACKAGE_python-pyasn1:python-light
  VARIANT:=python
endef

define Package/python3-pyasn1
$(call Package/python-pyasn1/Default)
  TITLE:=python3-pyasn1
  DEPENDS:=+PACKAGE_python3-pyasn1:python3-light
  VARIANT:=python3
endef

define Package/python-pyasn1/description
This is an implementation of ASN.1 types and codecs in Python programming
language. It has been first written to support particular protocol (SNMP)
but then generalized to be suitable for a wide range of protocols
based on ASN.1 specification.
endef

define Package/python3-pyasn1/description
$(call Package/python-pyasn1/description)
.
(Variant for Python3)
endef

$(eval $(call PyPackage,python-pyasn1))
$(eval $(call BuildPackage,python-pyasn1))
$(eval $(call BuildPackage,python-pyasn1-src))

$(eval $(call Py3Package,python3-pyasn1))
$(eval $(call BuildPackage,python3-pyasn1))
$(eval $(call BuildPackage,python3-pyasn1-src))
