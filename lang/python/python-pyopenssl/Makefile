#
# Copyright (C) 2015-2018 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-pyopenssl
PKG_VERSION:=19.0.0
PKG_RELEASE:=2

PYPI_NAME:=pyOpenSSL
PKG_HASH:=aeca66338f6de19d1aa46ed634c3b9ae519a64b458f8468aec688e7e3c20f200

PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Jeffery To <jeffery.to@gmail.com>, Alexandru Ardelean <ardeleanalex@gmail.com>
PKG_CPE_ID:=cpe:/a:pyopenssl_project:pyopenssl

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python-package.mk
include ../python3-package.mk

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
