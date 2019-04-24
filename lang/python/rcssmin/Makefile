#
# Copyright (C) 2007-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=rcssmin
PKG_VERSION:=1.0.6
PKG_RELEASE=2
PKG_LICENSE:=Apache-2.0

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/source/r/rcssmin
PKG_HASH:=ca87b695d3d7864157773a61263e5abb96006e9ff0e021eff90cbe0e1ba18270

include $(INCLUDE_DIR)/package.mk
include ../python-package.mk

define Package/rcssmin
    SUBMENU:=Python
    SECTION:=lang
    CATEGORY:=Languages
    TITLE:=Fast CSS minifier for Python
    MAINTAINER:=Gergely Kiss <mail.gery@gmail.com>
    URL:=http://opensource.perlig.de/rcssmin/
    DEPENDS:=+python
endef

define Package/rcssmin/description
    Fast CSS minifier for Python
endef

define Build/Compile
	$(call Build/Compile/PyMod,,install --prefix=/usr --root=$(PKG_INSTALL_DIR))
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)$(PYTHON_PKG_DIR)
	$(CP) \
	    $(PKG_INSTALL_DIR)$(PYTHON_PKG_DIR)/* \
	    $(1)$(PYTHON_PKG_DIR)
endef

define Package/rcssmin/install
	$(INSTALL_DIR) $(1)$(PYTHON_PKG_DIR)
	$(CP) \
	    $(PKG_INSTALL_DIR)$(PYTHON_PKG_DIR)/* \
	    $(1)$(PYTHON_PKG_DIR)
endef

$(eval $(call BuildPackage,rcssmin))
