#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=vcversioner
PKG_VERSION:=2.14.0.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://pypi.python.org/packages/source/v/vcversioner
PKG_MD5SUM:=7848a365ced9941053bc25d9a9f8f4b4

PKG_BUILD_DEPENDS:=python python-setuptools

PKG_LICENSE:=ISC
PKG_LICENSE_FILES:=vcversioner.py
PKG_MAINTAINER:=Jeffery To <jeffery.to@gmail.com>

include $(INCLUDE_DIR)/package.mk
$(call include_mk, python-package.mk)

define Package/python-vcversioner
	SECTION:=lang
	CATEGORY:=Languages
	SUBMENU:=Python
	TITLE:=python-vcversioner
	URL:=https://github.com/habnabit/vcversioner
	DEPENDS:=+python-light
endef

define Package/python-vcversioner/description
Elevator pitch: you can write a setup.py with no version information
specified, and vcversioner will find a recent, properly-formatted VCS
tag and extract a version from it.
endef

define Build/Compile
	$(call Build/Compile/PyMod,,install --prefix="/usr" --root="$(PKG_INSTALL_DIR)")
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)$(PYTHON_PKG_DIR)
	$(CP) \
		$(PKG_INSTALL_DIR)$(PYTHON_PKG_DIR)/* \
		$(1)$(PYTHON_PKG_DIR)
endef

$(eval $(call PyPackage,python-vcversioner))
$(eval $(call BuildPackage,python-vcversioner))
