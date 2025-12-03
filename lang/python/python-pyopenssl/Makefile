#
# Copyright (C) 2015-2016, 2018-2021, 2023 Jeffery To
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-pyopenssl
PKG_VERSION:=24.2.1
PKG_RELEASE:=1

PYPI_NAME:=pyOpenSSL
PYPI_SOURCE_NAME:=pyopenssl
PKG_HASH:=4247f0dbe3748d560dcbb2ff3ea01af0f9a1a001ef5f7c4c647956ed8cbf0e95

PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Jeffery To <jeffery.to@gmail.com>
PKG_CPE_ID:=cpe:/a:pyopenssl_project:pyopenssl

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-pyopenssl
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=OpenSSL wrapper
  URL:=https://pyopenssl.org/
  DEPENDS:= \
      +python3-light \
      +python3-openssl \
      +python3-cryptography
endef

define Package/python3-pyopenssl/description
Python wrapper module around the OpenSSL library
endef

$(eval $(call Py3Package,python3-pyopenssl))
$(eval $(call BuildPackage,python3-pyopenssl))
$(eval $(call BuildPackage,python3-pyopenssl-src))
