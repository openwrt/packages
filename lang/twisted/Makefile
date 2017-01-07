#
# Copyright (C) 2006-2011, 2015-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=twisted
PKG_VERSION:=16.4.1
PKG_RELEASE:=1

PKG_SOURCE:=Twisted-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=https://pypi.python.org/packages/6b/23/8dbe86fc83215015e221fbd861a545c6ec5c9e9cd7514af114d1f64084ab \
		http://twistedmatrix.com/Releases/Twisted/16.4
PKG_MD5SUM:=c6d09bdd681f538369659111f079c29d

PKG_BUILD_DIR:=$(BUILD_DIR)/Twisted-$(PKG_VERSION)
PKG_BUILD_DEPENDS:=python python-setuptools USE_MUSL:librpc

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Jeffery To <jeffery.to@gmail.com>

include $(INCLUDE_DIR)/package.mk
$(call include_mk, python-package.mk)

define Package/twisted
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Python networking engine
  URL:=http://twistedmatrix.com/
  DEPENDS:=+python-light +zope-interface
endef

define Package/twisted/description
 Twisted is a networking engine written in Python, supporting numerous
 protocols. It contains a web server, numerous chat clients, chat servers,
 mail servers, and more.
endef

define PyPackage/twisted/filespec
+|/usr/bin
-|/usr/bin/tkconch
+|$(PYTHON_PKG_DIR)
-|$(PYTHON_PKG_DIR)/twisted/conch/scripts/tkconch.py
endef

define Build/Compile
	$(call Build/Compile/PyMod,, \
		install --prefix="/usr" --root="$(PKG_INSTALL_DIR)" --no-compile, \
	)
endef

$(eval $(call PyPackage,twisted))
$(eval $(call BuildPackage,twisted))
