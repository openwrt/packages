#
# Copyright (C) 2015, 2017-2018 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-txsocksx
PKG_VERSION:=1.15.0.2
PKG_RELEASE:=4

PKG_SOURCE:=txsocksx-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/source/t/txsocksx
PKG_HASH:=4f79b5225ce29709bfcee45e6f726e65b70fd6f1399d1898e54303dbd6f8065f

PKG_BUILD_DIR:=$(BUILD_DIR)/$(BUILD_VARIANT)-txsocksx-$(PKG_VERSION)

PKG_LICENSE:=ISC
PKG_LICENSE_FILES:=COPYING
PKG_MAINTAINER:=Jeffery To <jeffery.to@gmail.com>

include $(INCLUDE_DIR)/package.mk
include ../python-package.mk

PKG_UNPACK:=$(HOST_TAR) -C $(PKG_BUILD_DIR) --strip-components=1 -xzf $(DL_DIR)/$(PKG_SOURCE)

PYTHON_PKG_SETUP_VARS:= \
  PKG_VERSION="$(PKG_VERSION)"

define Package/python-txsocksx/Default
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=SOCKS client endpoints for Twisted
  URL:=https://github.com/habnabit/txsocksx
endef

define Package/python-txsocksx
$(call Package/python-txsocksx/Default)
  DEPENDS:= \
      +PACKAGE_python-txsocksx:python-light \
      +PACKAGE_python-txsocksx:python-parsley \
      +PACKAGE_python-txsocksx:python-twisted
  VARIANT:=python
endef

define Package/python-txsocksx/description
txsocksx is SOCKS4/4a and SOCKS5 client endpoints for Twisted 10.1 or
greater.
endef

$(eval $(call PyPackage,python-txsocksx))
$(eval $(call BuildPackage,python-txsocksx))
$(eval $(call BuildPackage,python-txsocksx-src))
