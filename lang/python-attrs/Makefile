#
# Copyright (C) 2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=attrs
PKG_VERSION:=16.0.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://pypi.python.org/packages/89/15/80d388d696c8c8ba14874635207aa698eb30ef1242dbb54d9eccf0e927ff
PKG_MD5SUM:=5bcdd418f6e83e580434c63067c08a73

PKG_BUILD_DEPENDS:=python python-setuptools

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Jeffery To <jeffery.to@gmail.com>

include $(INCLUDE_DIR)/package.mk
$(call include_mk, python-package.mk)

define Package/python-attrs
	SECTION:=lang
	CATEGORY:=Languages
	SUBMENU:=Python
	TITLE:=python-attrs
	URL:=https://attrs.readthedocs.org/
	DEPENDS:=+python-light
endef

define Package/python-attrs/description
attrs is an MIT-licensed Python package with class decorators that ease
the chores of implementing the most common attribute-related object
protocols.
endef

define Build/Compile
	$(call Build/Compile/PyMod,,install --prefix="/usr" --root="$(PKG_INSTALL_DIR)")
endef

$(eval $(call PyPackage,python-attrs))
$(eval $(call BuildPackage,python-attrs))
