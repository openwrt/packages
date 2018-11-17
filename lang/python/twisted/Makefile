#
# Copyright (C) 2006-2011, 2015-2018 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=twisted
PKG_VERSION:=18.9.0
PKG_RELEASE:=1

PKG_SOURCE:=Twisted-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/source/T/Twisted
PKG_HASH:=294be2c6bf84ae776df2fc98e7af7d6537e1c5e60a46d33c3ce2a197677da395

PKG_BUILD_DIR:=$(BUILD_DIR)/$(BUILD_VARIANT)-twisted-$(PKG_VERSION)
PKG_BUILD_DEPENDS:=libtirpc

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Jeffery To <jeffery.to@gmail.com>

include $(INCLUDE_DIR)/package.mk
include ../python-package.mk

PKG_UNPACK:=$(HOST_TAR) -C $(PKG_BUILD_DIR) --strip-components=1 -xjf $(DL_DIR)/$(PKG_SOURCE)

define Package/twisted/Default
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  URL:=http://twistedmatrix.com/
endef

define Package/twisted
$(call Package/twisted/Default)
  TITLE:=Python networking engine
  DEPENDS:= \
      +PACKAGE_twisted:python-light \
      +PACKAGE_twisted:python-attrs \
      +PACKAGE_twisted:python-automat \
      +PACKAGE_twisted:python-constantly \
      +PACKAGE_twisted:python-incremental \
      +PACKAGE_twisted:python-hyperlink \
      +PACKAGE_twisted:python-zope-interface
  VARIANT:=python
endef

define Package/twisted/description
Twisted is a networking engine written in Python, supporting numerous
protocols. It contains a web server, numerous chat clients, chat servers,
mail servers, and more.
endef

define PyPackage/twisted/filespec
+|/usr/bin
+|$(PYTHON_PKG_DIR)
-|$(PYTHON_PKG_DIR)/twisted/conch/scripts/tkconch.py
endef

$(eval $(call PyPackage,twisted))
$(eval $(call BuildPackage,twisted))
$(eval $(call BuildPackage,twisted-src))
