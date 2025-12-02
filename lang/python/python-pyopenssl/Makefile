#
# Copyright (C) 2015-2016, 2018-2021, 2023 Jeffery To
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-pyopenssl
PKG_VERSION:=23.3.0
PKG_RELEASE:=1

PYPI_NAME:=pyOpenSSL
PYPI_SOURCE_NAME:=pyopenssl
PKG_HASH:=6b2cba5cc46e822750ec3e5a81ee12819850b11303630d575e98108a079c2b12

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
