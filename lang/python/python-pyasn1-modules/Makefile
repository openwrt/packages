#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=pyasn1-modules
PKG_VERSION:=0.0.8
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://pypi.python.org/packages/source/p/pyasn1-modules
PKG_MD5SUM:=178129bc7fbf07215c25230c5f053f81

PKG_BUILD_DEPENDS:=python python-setuptools

PKG_LICENSE:=BSD-2-Clause
PKG_LICENSE_FILES:=LICENSE.txt
PKG_MAINTAINER:=Jeffery To <jeffery.to@gmail.com>

include $(INCLUDE_DIR)/package.mk
$(call include_mk, python-package.mk)

define Package/python-pyasn1-modules
	SECTION:=lang
	CATEGORY:=Languages
	SUBMENU:=Python
	TITLE:=python-pyasn1-modules
	URL:=http://sourceforge.net/projects/pyasn1/
	DEPENDS:=+python-light +python-pyasn1
endef

define Package/python-pyasn1-modules/description
This is a small but growing collection of ASN.1 data structures
expressed in Python terms using pyasn1 data model.
endef

define Build/Compile
	$(call Build/Compile/PyMod,,install --prefix="/usr" --root="$(PKG_INSTALL_DIR)")
endef

$(eval $(call PyPackage,python-pyasn1-modules))
$(eval $(call BuildPackage,python-pyasn1-modules))
