#
# Copyright (C) 2007-2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=gunicorn
PKG_VERSION:=19.7.1
PKG_RELEASE=1
PKG_LICENSE:=MIT

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://pypi.python.org/packages/30/3a/10bb213cede0cc4d13ac2263316c872a64bf4c819000c8ccd801f1d5f822/
PKG_HASH:=eee1169f0ca667be05db3351a0960765620dad53f53434262ff8901b68a1b622

include $(INCLUDE_DIR)/package.mk
include ../python-package.mk

define Package/gunicorn
    SUBMENU:=Python
    SECTION:=lang
    CATEGORY:=Languages
    TITLE:=WSGI HTTP Server for UNIX
    MAINTAINER:=Gergely Kiss <mail.gery@gmail.com>
    URL:=http://gunicorn.org/
    DEPENDS:=+python +python-setuptools
endef

define Package/gunicorn/description
    WSGI HTTP Server for UNIX
endef

define Build/Compile
	$(call Build/Compile/PyMod,,install --prefix=/usr --root=$(PKG_INSTALL_DIR))
endef

define Package/gunicorn/install
	$(INSTALL_DIR) $(1)$(PYTHON_PKG_DIR)
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) \
	    $(PKG_INSTALL_DIR)$(PYTHON_PKG_DIR)/* \
	    $(1)$(PYTHON_PKG_DIR)
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/gunicorn* \
	    $(1)/usr/bin
	# fix python exec path in scripts
	$(SED) 's/#!.*/#!\/usr\/bin\/python/g' $(1)/usr/bin/gunicorn*
endef

$(eval $(call BuildPackage,gunicorn))
