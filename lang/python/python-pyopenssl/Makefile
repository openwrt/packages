#
# Copyright (C) 2015-2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=pyOpenSSL
PKG_VERSION:=17.2.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://pypi.python.org/packages/b0/9e/7088f6165c40c46416aff434eb806c1d64ad6ec6dbc201f5ad4d0484704e
PKG_HASH:=5d617ce36b07c51f330aa63b83bf7f25c40a0e95958876d54d1982f8c91b4834

PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Jeffery To <jeffery.to@gmail.com>, Alexandru Ardelean <ardeleanalex@gmail.com>

PKG_BUILD_DIR:=$(BUILD_DIR)/$(BUILD_VARIANT)-pyopenssl-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
$(call include_mk, python-package.mk)
$(call include_mk, python3-package.mk)

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
$(eval $(call Py3Package,python3-pyopenssl))
$(eval $(call BuildPackage,python3-pyopenssl))
