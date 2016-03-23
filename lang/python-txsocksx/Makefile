#
# Copyright (C) 2015-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=txsocksx
PKG_VERSION:=1.15.0.2
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://pypi.python.org/packages/source/t/txsocksx
PKG_MD5SUM:=0266b9ae7b58f7550a49683afebf65ba

PKG_BUILD_DEPENDS:=python python-setuptools

PKG_LICENSE:=ISC
PKG_LICENSE_FILES:=COPYING
PKG_MAINTAINER:=Jeffery To <jeffery.to@gmail.com>

include $(INCLUDE_DIR)/package.mk
$(call include_mk, python-package.mk)

define Package/python-txsocksx
	SECTION:=lang
	CATEGORY:=Languages
	SUBMENU:=Python
	TITLE:=python-txsocksx
	URL:=https://github.com/habnabit/txsocksx
	DEPENDS:=+python-light +python-parsley +twisted
endef

define Package/python-txsocksx/description
txsocksx is SOCKS4/4a and SOCKS5 client endpoints for Twisted 10.1 or
greater.
endef

define Build/Compile
	$(call Build/Compile/PyMod,, \
		install --prefix="/usr" --root="$(PKG_INSTALL_DIR)", \
		PKG_VERSION="$(PKG_VERSION)" \
	)
endef

$(eval $(call PyPackage,python-txsocksx))
$(eval $(call BuildPackage,python-txsocksx))
