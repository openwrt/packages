#
# Copyright (C) 2007-2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=greenlet
PKG_VERSION:=0.4.12
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://pypi.python.org/packages/be/76/82af375d98724054b7e273b5d9369346937324f9bcc20980b45b068ef0b0/
PKG_MD5SUM:=e8637647d58a26c4a1f51ca393e53c00

PKG_BUILD_DEPENDS:=python python-setuptools
PKG_USE_MIPS16:=0

include $(INCLUDE_DIR)/package.mk
$(call include_mk, python-package.mk)

define Package/python-greenlet
	SUBMENU:=Python
	SECTION:=lang
	CATEGORY:=Languages
	MAINTAINER:=V.E.O <veo at live.com>
	TITLE:=Lightweight in-process concurrent programming
	URL:=https://github.com/python-greenlet/greenlet
	DEPENDS:=+python-light
endef

define Package/python-greenlet/description
Greenlets are lightweight coroutines for in-process concurrent
programming.
endef


define Build/Prepare
$(call Build/Prepare/Default)
	rm -f $(PKG_BUILD_DIR)/src/greenlet/{_socket,_ssl}3.py
endef

define Build/Compile
	$(call Build/Compile/PyMod,,install --prefix=/usr --root=$(PKG_INSTALL_DIR))
endef

$(eval $(call PyPackage,python-greenlet))
$(eval $(call BuildPackage,python-greenlet))
