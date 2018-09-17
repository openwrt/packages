#
# Copyright (C) 2007-2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-dateutil
PKG_VERSION:=2.7.3
PKG_RELEASE:=1
PKG_LICENSE:=BSD-2-Clause

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/source/p/python-dateutil
PKG_HASH:=e27001de32f627c22380a688bcc43ce83504a7bc5da472209b4c70f02829f0b8

include $(INCLUDE_DIR)/package.mk
include ../python-package.mk

define Package/python-dateutil
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  MAINTAINER:=Gergely Kiss <mail.gery@gmail.com>
  TITLE:=Extensions to the standard Python datetime module
  URL:=https://dateutil.readthedocs.org/
  DEPENDS:=+python +python-six
endef

define Package/python-dateutil/description
  Extensions to the standard Python datetime module
endef

define Build/Compile
	$(call Build/Compile/PyMod,,install --prefix=/usr --root=$(PKG_INSTALL_DIR))
endef

define Package/python-dateutil/install
	$(INSTALL_DIR) $(1)$(PYTHON_PKG_DIR)
	$(CP) \
	    $(PKG_INSTALL_DIR)$(PYTHON_PKG_DIR)/* \
	    $(1)$(PYTHON_PKG_DIR)
endef

$(eval $(call BuildPackage,python-dateutil))
