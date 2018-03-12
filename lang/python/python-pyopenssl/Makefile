#
# Copyright (C) 2015-2018 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-pyopenssl
PKG_VERSION:=17.5.0
PKG_RELEASE:=2

PKG_SOURCE:=pyOpenSSL-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://pypi.python.org/packages/3b/15/a5d90ab1a41075e8f0fae334f13452549528f82142b3b9d0c9d86ab7178c
PKG_HASH:=2c10cfba46a52c0b0950118981d61e72c1e5b1aac451ca1bc77de1a679456773

PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Jeffery To <jeffery.to@gmail.com>, Alexandru Ardelean <ardeleanalex@gmail.com>

PKG_BUILD_DIR:=$(BUILD_DIR)/$(BUILD_VARIANT)-pyopenssl-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include ../python-package.mk
include ../python3-package.mk

PKG_UNPACK:=$(HOST_TAR) -C $(PKG_BUILD_DIR) --strip-components=1 -xzf $(DL_DIR)/$(PKG_SOURCE)

define Package/python-pyopenssl/Default
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  URL:=https://github.com/pyca/pyopenssl
endef

define Package/python-pyopenssl
$(call Package/python-pyopenssl/Default)
  TITLE:=python-pyopenssl
  VARIANT:=python
  DEPENDS:= \
      +PACKAGE_python-pyopenssl:python-light \
      +PACKAGE_python-pyopenssl:python-cryptography \
      +PACKAGE_python-pyopenssl:python-six
endef

define Package/python3-pyopenssl
$(call Package/python-pyopenssl/Default)
  TITLE:=python3-pyopenssl
  VARIANT:=python3
  DEPENDS:= \
      +PACKAGE_python3-pyopenssl:python3-light \
      +PACKAGE_python3-pyopenssl:python3-cryptography \
      +PACKAGE_python3-pyopenssl:python3-six
endef

define Package/python-pyopenssl/description
Python wrapper module around the OpenSSL library
endef

define Package/python3-pyopenssl/description
$(call Package/python-pyopenssl/description)
.
(Variant for Python3).
endef

$(eval $(call PyPackage,python-pyopenssl))
$(eval $(call BuildPackage,python-pyopenssl))
$(eval $(call BuildPackage,python-pyopenssl-src))

$(eval $(call Py3Package,python3-pyopenssl))
$(eval $(call BuildPackage,python3-pyopenssl))
$(eval $(call BuildPackage,python3-pyopenssl-src))
