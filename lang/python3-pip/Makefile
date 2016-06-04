#
# Copyright (C) 2014-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python3-pip
PKG_VERSION:=8.1.2
PKG_RELEASE:=1

PKG_SOURCE:=pip-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://pypi.python.org/packages/e7/a8/7556133689add8d1a54c0b14aeff0acb03c64707ce100ecd53934da1aa13/
PKG_MD5SUM:=87083c0b9867963b29f7aba3613e8f4a

PKG_LICENSE:=MIT

PKG_BUILD_DIR:=$(BUILD_DIR)/python3-pip-$(PKG_VERSION)
PKG_UNPACK=$(HOST_TAR) -C $(PKG_BUILD_DIR) --strip-components=1 -xzf $(DL_DIR)/$(PKG_SOURCE)
PKG_USE_MIPS16:=0

include $(INCLUDE_DIR)/package.mk
$(call include_mk, python3-package.mk)

define Package/python3-pip
	SUBMENU:=Python
	SECTION:=lang
	CATEGORY:=Languages
	TITLE:=Tool for installing Python $(PYTHON3_VERSION) packages.
	URL:=https://pip.pypa.io
	DEPENDS:=+python3 +python3-dev +python3-lib2to3 +python3-setuptools
	MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>
endef

define Package/python3-pip/description
	A tool for installing and managing Python $(PYTHON3_VERSION) packages.
endef

define Build/Compile
	$(call Build/Compile/Py3Mod,,\
		install --root="$(PKG_INSTALL_DIR)" --prefix="/usr" \
		--single-version-externally-managed \
	)
endef

define Py3Package/python3-pip/filespec
+|$(PYTHON3_PKG_DIR)
-|$(PYTHON3_PKG_DIR)/_vendor/distlib/*.exe
-|$(PYTHON3_PKG_DIR)/utils/outdated.py
endef

define Py3Package/python3-pip/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/pip$(PYTHON3_VERSION) $(1)/usr/bin
	$(LN) pip$(PYTHON3_VERSION) $(1)/usr/bin/pip3
endef

$(eval $(call Py3Package,python3-pip))
$(eval $(call BuildPackage,python3-pip))
