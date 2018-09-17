#
# Copyright (C) 2007-2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=jdcal
PKG_VERSION:=1.4
PKG_RELEASE:=1
PKG_LICENSE:=BSD-3-Clause

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/source/j/jdcal
PKG_HASH:=ea0a5067c5f0f50ad4c7bdc80abad3d976604f6fb026b0b3a17a9d84bb9046c9

include $(INCLUDE_DIR)/package.mk
include ../python-package.mk

define Package/jdcal
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  MAINTAINER:=Gergely Kiss <mail.gery@gmail.com>
  TITLE:=Julian dates from proleptic Gregorian and Julian calendars.
  URL:=https://github.com/phn/jdcal
  DEPENDS:=+python
endef

define Package/jdcal/description
  Julian dates from proleptic Gregorian and Julian calendars.
endef

define Build/Compile
	$(call Build/Compile/PyMod,,install --prefix=/usr --root=$(PKG_INSTALL_DIR))
endef

define Package/jdcal/install
	$(INSTALL_DIR) $(1)$(PYTHON_PKG_DIR)
	$(CP) \
	    $(PKG_INSTALL_DIR)$(PYTHON_PKG_DIR)/* \
	    $(1)$(PYTHON_PKG_DIR)
endef

$(eval $(call BuildPackage,jdcal))
