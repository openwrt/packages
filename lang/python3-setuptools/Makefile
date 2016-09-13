#
# Copyright (C) 2014-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python3-setuptools
PKG_VERSION:=27.1.2
PKG_RELEASE:=1

PKG_SOURCE:=setuptools-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://pypi.python.org/packages/7b/e7/d9b468ead9854ca55110325ce00ae6ee64d11b957cc5214aa5174738187e/
PKG_MD5SUM:=75e60f2aee3d423a53d32e234a2328e1

PKG_LICENSE:=PSF

PKG_BUILD_DIR:=$(BUILD_DIR)/python3-setuptools-$(PKG_VERSION)
PKG_UNPACK=$(HOST_TAR) -C $(PKG_BUILD_DIR) --strip-components=1 -xzf $(DL_DIR)/$(PKG_SOURCE)

include $(INCLUDE_DIR)/package.mk
$(call include_mk, python3-package.mk)

define Package/python3-setuptools
	SUBMENU:=Python
	SECTION:=lang
	CATEGORY:=Languages
	TITLE:=Tool for installing Python $(PYTHON3_VERSION) packages.
	URL:=https://bitbucket.org/pypa/setuptools
	DEPENDS:=+python3 +python3-dev +python3-lib2to3
	MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>
endef

define Package/python3-setuptools/description
	Easily download, build, install, upgrade, and uninstall Python $(PYTHON3_VERSION) packages
endef

define Build/Compile
	$(call Build/Compile/Py3Mod,,\
		install --root="$(PKG_INSTALL_DIR)" --prefix="/usr" \
		--single-version-externally-managed \
	)
endef

define Build/InstallDev
	$(INSTALL_DIR) $(PYTHON3_LIB_DIR)
	$(CP) \
		$(PKG_INSTALL_DIR)$(PYTHON3_PKG_DIR)/* \
		$(PYTHON3_LIB_DIR)
endef

define Py3Package/python3-setuptools/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/easy_install-$(PYTHON3_VERSION) $(1)/usr/bin/
	$(LN) easy_install-$(PYTHON3_VERSION) $(1)/usr/bin/easy_install3
endef

$(eval $(call Py3Package,python3-setuptools))
$(eval $(call BuildPackage,python3-setuptools))
