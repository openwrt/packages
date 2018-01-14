#
# Copyright (C) 2016-2018 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-service-identity
PKG_VERSION:=17.0.0
PKG_RELEASE:=2

PKG_SOURCE:=service_identity-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://pypi.python.org/packages/de/2a/cab6e30be82c8fcd2339ef618036720eda954cf05daef514e386661c9221
PKG_HASH:=4001fbb3da19e0df22c47a06d29681a398473af4aa9d745eca525b3b2c2302ab

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
  URL:=https://github.com/pyca/service_identity
endef

define Package/python-service-identity
$(call Package/python-service-identity/Default)
  TITLE:=python-service-identity
  DEPENDS:= \
      +PACKAGE_python-service-identity:python-light \
      +PACKAGE_python-service-identity:python-attrs \
      +PACKAGE_python-service-identity:python-pyasn1 \
      +PACKAGE_python-service-identity:python-pyasn1-modules \
      +PACKAGE_python-service-identity:python-pyopenssl
  VARIANT:=python
endef

define Package/python3-service-identity
$(call Package/python-service-identity/Default)
  TITLE:=python3-service-identity
  DEPENDS:= \
      +PACKAGE_python3-service-identity:python3-light \
      +PACKAGE_python3-service-identity:python3-attrs \
      +PACKAGE_python3-service-identity:python3-pyasn1 \
      +PACKAGE_python3-service-identity:python3-pyasn1-modules \
      +PACKAGE_python3-service-identity:python3-pyopenssl
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
