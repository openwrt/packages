#
# Copyright (C) 2015, 2017-2018 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-txsocksx
PKG_VERSION:=1.15.0.2
PKG_RELEASE:=2

PKG_SOURCE:=txsocksx-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://pypi.python.org/packages/source/t/txsocksx
PKG_HASH:=4f79b5225ce29709bfcee45e6f726e65b70fd6f1399d1898e54303dbd6f8065f

PKG_BUILD_DIR:=$(BUILD_DIR)/$(BUILD_VARIANT)-txsocksx-$(PKG_VERSION)

PKG_LICENSE:=ISC
PKG_LICENSE_FILES:=COPYING
PKG_MAINTAINER:=Jeffery To <jeffery.to@gmail.com>

include $(INCLUDE_DIR)/package.mk
include ../python-package.mk

PKG_UNPACK:=$(HOST_TAR) -C $(PKG_BUILD_DIR) --strip-components=1 -xzf $(DL_DIR)/$(PKG_SOURCE)

define Package/python-txsocksx/Default
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  URL:=https://github.com/habnabit/txsocksx
endef

define Package/python-txsocksx
$(call Package/python-txsocksx/Default)
  TITLE:=python-txsocksx
  DEPENDS:= \
      +PACKAGE_python-txsocksx:python-light \
      +PACKAGE_python-txsocksx:python-parsley \
      +PACKAGE_python-txsocksx:twisted
  VARIANT:=python
endef

define Package/python-txsocksx/description
txsocksx is SOCKS4/4a and SOCKS5 client endpoints for Twisted 10.1 or
greater.
endef

define PyBuild/Compile
	$(call Build/Compile/PyMod,, \
		install --prefix="/usr" --root="$(PKG_INSTALL_DIR)", \
		PKG_VERSION="$(PKG_VERSION)" \
	)
endef

$(eval $(call PyPackage,python-txsocksx))
$(eval $(call BuildPackage,python-txsocksx))
$(eval $(call BuildPackage,python-txsocksx-src))
