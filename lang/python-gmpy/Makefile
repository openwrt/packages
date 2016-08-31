#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=gmpy
PKG_VERSION:=1.17
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).zip
PKG_SOURCE_URL:=https://pypi.python.org/packages/source/g/gmpy
PKG_MD5SUM:=2bf419076b06e107167e219f60ac6d27

PKG_LICENSE:=LGPL-2.1+
PKG_LICENSE_FILES:=lgpl-2.1.txt
PKG_MAINTAINER:=Jeffery To <jeffery.to@gmail.com>

include $(INCLUDE_DIR)/package.mk
$(call include_mk, python-package.mk)

define Package/python-gmpy
	SECTION:=lang
	CATEGORY:=Languages
	SUBMENU:=Python
	TITLE:=python-gmpy
	URL:=http://code.google.com/p/gmpy/
	DEPENDS:=+libgmp +python-light
endef

define Package/python-gmpy/description
gmpy is a C-coded Python extension module that provides access to the
GMP (or MPIR) multiple-precision arithmetic library.
endef

define Build/Compile
	$(call Build/Compile/PyMod,,install --prefix="/usr" --root="$(PKG_INSTALL_DIR)")
endef

$(eval $(call PyPackage,python-gmpy))
$(eval $(call BuildPackage,python-gmpy))
