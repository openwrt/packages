#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-pyasn1
PKG_VERSION:=0.3.5
PKG_RELEASE:=1

PKG_SOURCE:=pyasn1-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://pypi.python.org/packages/bc/85/029f5f4d4fa8a487538ce597932cf3601bba3392c85d74eae148fe6ac5d3
PKG_HASH:=c7a1186416bcdaf19b56f5b2506200306d7d4cf222d3d7c2d4cb600ccacdaf1b

PKG_LICENSE:=BSD-2-Clause
PKG_LICENSE_FILES:=LICENSE.txt
PKG_MAINTAINER:=Jeffery To <jeffery.to@gmail.com>, Alexandru Ardelean <ardeleanalex@gmail.com>

PKG_BUILD_DIR:=$(BUILD_DIR)/$(BUILD_VARIANT)-pyasn1-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
$(call include_mk, python-package.mk)
$(call include_mk, python3-package.mk)

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
$(eval $(call Py3Package,python3-pyasn1))
$(eval $(call BuildPackage,python3-pyasn1))
