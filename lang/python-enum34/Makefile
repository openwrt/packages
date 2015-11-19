#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=enum34
PKG_VERSION:=1.0.4
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://pypi.python.org/packages/source/e/enum34
PKG_MD5SUM:=ac80f432ac9373e7d162834b264034b6

PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=enum/LICENSE
PKG_MAINTAINER:=Jeffery To <jeffery.to@gmail.com>

include $(INCLUDE_DIR)/package.mk
$(call include_mk, python-package.mk)

define Package/python-enum34
	SECTION:=lang
	CATEGORY:=Languages
	SUBMENU:=Python
	TITLE:=python-enum34
	URL:=https://pypi.python.org/pypi/enum34/
	DEPENDS:=+python-light
endef

define Package/python-enum34/description
enum34 is the new Python stdlib enum module available in Python 3.4
backported for previous versions of Python from 2.4 to 3.3.
endef

define Build/Compile
	$(call Build/Compile/PyMod,,install --prefix=/usr --root=$(PKG_INSTALL_DIR))
endef

$(eval $(call PyPackage,python-enum34))
$(eval $(call BuildPackage,python-enum34))
