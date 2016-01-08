#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=pyOpenSSL
PKG_VERSION:=0.15.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://pypi.python.org/packages/source/p/pyOpenSSL
PKG_MD5SUM:=f447644afcbd5f0a1f47350fec63a4c6

PKG_BUILD_DEPENDS:=python python-setuptools

PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Jeffery To <jeffery.to@gmail.com>

include $(INCLUDE_DIR)/package.mk
$(call include_mk, python-package.mk)

define Package/python-pyopenssl
	SECTION:=lang
	CATEGORY:=Languages
	SUBMENU:=Python
	TITLE:=python-pyopenssl
	URL:=https://github.com/pyca/pyopenssl
	DEPENDS:=+python-light +python-cryptography +python-six
endef

define Package/python-pyopenssl/description
Python wrapper module around the OpenSSL library
endef

define Build/Compile
	$(call Build/Compile/PyMod,,install --prefix="/usr" --root="$(PKG_INSTALL_DIR)")
endef

$(eval $(call PyPackage,python-pyopenssl))
$(eval $(call BuildPackage,python-pyopenssl))
