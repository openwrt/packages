#
# Copyright (C) 2015, 2018-2020, 2023 Jeffery To
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-pyasn1
PKG_VERSION:=0.5.1
PKG_RELEASE:=1

PYPI_NAME:=pyasn1
PKG_HASH:=6d391a96e59b23130a5cfa74d6fd7f388dbbe26cc8f1edf39fdddf08d9d6676c

PKG_LICENSE:=BSD-2-Clause
PKG_LICENSE_FILES:=LICENSE.rst
PKG_MAINTAINER:=Jeffery To <jeffery.to@gmail.com>

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-pyasn1
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=ASN.1 types and DER/BER/CER codecs (X.208)
  URL:=https://github.com/pyasn1/pyasn1
  DEPENDS:=+python3-light +python3-logging
endef

define Package/python3-pyasn1/description
This is an implementation of ASN.1 types and codecs in Python programming
language. It has been first written to support particular protocol (SNMP)
but then generalized to be suitable for a wide range of protocols
based on ASN.1 specification.
endef

$(eval $(call Py3Package,python3-pyasn1))
$(eval $(call BuildPackage,python3-pyasn1))
$(eval $(call BuildPackage,python3-pyasn1-src))
