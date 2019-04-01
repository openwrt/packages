#
# Copyright (C) 2019 CZ.NIC, z. s. p. o. (https://www.nic.cz/)
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-pluggy
PKG_VERSION:=0.12.0
PKG_RELEASE:=1

PKG_SOURCE:=pluggy-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/source/p/pluggy/
PKG_HASH:=0825a152ac059776623854c1543d65a4ad408eb3d33ee114dff91e57ec6ae6fc
PKG_BUILD_DIR:=$(BUILD_DIR)/pluggy-$(PKG_VERSION)

PKG_MAINTAINER:=Jan Pavlinec <jan.pavlinec@nic.cz>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

PYTHON3_PKG_SETUP_VARS:= \
        PKG_VERSION="$(PKG_VERSION)"

define Package/python3-pluggy
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Plugin and hook calling mechanisms for Python
  URL:=https://github.com/pytest-dev/pluggy
  DEPENDS:=+python3-light +python3-importlib-metadata
  VARIANT:=python3
endef

define Package/python3-pluggy/description
  A minimalist production ready plugin system for python
endef

define Py3Build/Compile
	echo "version = \"$(PKG_VERSION)\"" > $(PKG_BUILD_DIR)/src/pluggy/_version.py
	$(call Py3Build/Compile/Default)
endef

$(eval $(call Py3Package,python3-pluggy))
$(eval $(call BuildPackage,python3-pluggy))
$(eval $(call BuildPackage,python3-pluggy-src))
