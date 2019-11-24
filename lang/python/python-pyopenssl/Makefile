#
# Copyright (C) 2015-2018 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-pyopenssl
PKG_VERSION:=19.1.0
PKG_RELEASE:=1

PKG_SOURCE:=pyOpenSSL-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/source/p/pyOpenSSL
PKG_HASH:=9a24494b2602aaf402be5c9e30a0b82d4a5c67528fe8fb475e3f3bc00dd69507

PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Jeffery To <jeffery.to@gmail.com>, Alexandru Ardelean <ardeleanalex@gmail.com>
PKG_CPE_ID:=cpe:/a:pyopenssl_project:pyopenssl

PKG_BUILD_DIR:=$(BUILD_DIR)/$(BUILD_VARIANT)-pyopenssl-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include ../python-package.mk
include ../python3-package.mk

PKG_UNPACK:=$(HOST_TAR) -C $(PKG_BUILD_DIR) --strip-components=1 -xzf $(DL_DIR)/$(PKG_SOURCE)

define Package/python-pyopenssl/Default
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=OpenSSL wrapper
  URL:=https://pyopenssl.org/
endef

define Package/python-pyopenssl
$(call Package/python-pyopenssl/Default)
  DEPENDS:= \
      +PACKAGE_python-pyopenssl:python-light \
      +PACKAGE_python-pyopenssl:python-cryptography \
      +PACKAGE_python-pyopenssl:python-six
  VARIANT:=python
endef

define Package/python3-pyopenssl
$(call Package/python-pyopenssl/Default)
  DEPENDS:= \
      +PACKAGE_python3-pyopenssl:python3-light \
      +PACKAGE_python3-pyopenssl:python3-cryptography \
      +PACKAGE_python3-pyopenssl:python3-six
  VARIANT:=python3
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
