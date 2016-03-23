#
# Copyright (C) 2006-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=twisted
PKG_VERSION:=16.0.0
PKG_RELEASE:=1

PKG_SOURCE:=Twisted-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=https://pypi.python.org/packages/source/T/Twisted \
		http://twistedmatrix.com/Releases/Twisted/16.0
PKG_MD5SUM:=c6aa35e9a1e40fce6797247f39647d2a

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
-|/usr/bin/manhole
-|/usr/bin/tap2deb
-|/usr/bin/tap2rpm
-|/usr/bin/tkconch
+|$(PYTHON_PKG_DIR)
-|$(PYTHON_PKG_DIR)/twisted/conch/scripts/tkconch.py
-|$(PYTHON_PKG_DIR)/twisted/scripts/manhole.py
-|$(PYTHON_PKG_DIR)/twisted/scripts/tap2deb.py
-|$(PYTHON_PKG_DIR)/twisted/scripts/tap2rpm.py
endef

define Build/Compile
	$(call Build/Compile/PyMod,, \
		install --prefix="/usr" --root="$(PKG_INSTALL_DIR)" --no-compile, \
	)
endef

$(eval $(call PyPackage,twisted))
$(eval $(call BuildPackage,twisted))
