#
# Copyright (C) 2015-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=idna
PKG_VERSION:=2.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://pypi.python.org/packages/source/i/idna
PKG_MD5SUM:=f6473caa9c5e0cc1ad3fd5d04c3c114b

PKG_BUILD_DEPENDS:=python python-setuptools

PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE.rst
PKG_MAINTAINER:=Jeffery To <jeffery.to@gmail.com>

include $(INCLUDE_DIR)/package.mk
$(call include_mk, python-package.mk)

define Package/python-idna
	SECTION:=lang
	CATEGORY:=Languages
	SUBMENU:=Python
	TITLE:=python-idna
	URL:=https://github.com/kjd/idna
	DEPENDS:=+python-light
endef

define Package/python-idna/description
A library to support the Internationalised Domain Names in Applications
(IDNA) protocol as specified in RFC 5891. This version of the protocol
is often referred to as "IDNA2008" and can produce different results
from the earlier standard from 2003.
endef

define Build/Compile
	$(call Build/Compile/PyMod,,install --prefix=/usr --root=$(PKG_INSTALL_DIR))
endef

$(eval $(call PyPackage,python-idna))
$(eval $(call BuildPackage,python-idna))
