#
# Copyright (C) 2016-2018 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-service-identity
PKG_VERSION:=18.1.0
PKG_RELEASE:=1

PKG_SOURCE:=service_identity-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/source/s/service_identity
PKG_HASH:=0858a54aabc5b459d1aafa8a518ed2081a285087f349fe3e55197989232e2e2d

PKG_BUILD_DIR:=$(BUILD_DIR)/$(BUILD_VARIANT)-service-identity-$(PKG_VERSION)

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Jeffery To <jeffery.to@gmail.com>

include $(INCLUDE_DIR)/package.mk
include ../python-package.mk
include ../python3-package.mk

PKG_UNPACK:=$(HOST_TAR) -C $(PKG_BUILD_DIR) --strip-components=1 -xzf $(DL_DIR)/$(PKG_SOURCE)

define Package/python-service-identity/Default
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Service identity verification
  URL:=https://service-identity.readthedocs.io/
endef

define Package/python-service-identity
$(call Package/python-service-identity/Default)
  DEPENDS:= \
      +PACKAGE_python-service-identity:python-light \
      +PACKAGE_python-service-identity:python-attrs \
      +PACKAGE_python-service-identity:python-cryptography \
      +PACKAGE_python-service-identity:python-ipaddress \
      +PACKAGE_python-service-identity:python-pyasn1 \
      +PACKAGE_python-service-identity:python-pyasn1-modules
  VARIANT:=python
endef

define Package/python3-service-identity
$(call Package/python-service-identity/Default)
  DEPENDS:= \
      +PACKAGE_python3-service-identity:python3-light \
      +PACKAGE_python3-service-identity:python3-attrs \
      +PACKAGE_python3-service-identity:python3-cryptography \
      +PACKAGE_python3-service-identity:python3-pyasn1 \
      +PACKAGE_python3-service-identity:python3-pyasn1-modules
  VARIANT:=python3
endef

define Package/python-service-identity/description
service_identity aspires to give you all the tools you need for
verifying whether a certificate is valid for the intended purposes.
endef

define Package/python3-service-identity/description
$(call Package/python-service-identity/description)
.
(Variant for Python3)
endef

$(eval $(call PyPackage,python-service-identity))
$(eval $(call BuildPackage,python-service-identity))
$(eval $(call BuildPackage,python-service-identity-src))

$(eval $(call Py3Package,python3-service-identity))
$(eval $(call BuildPackage,python3-service-identity))
$(eval $(call BuildPackage,python3-service-identity-src))
