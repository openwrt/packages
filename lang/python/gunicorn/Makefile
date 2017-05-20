#
# Copyright (C) 2007-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=gunicorn
PKG_VERSION:=19.6.0
PKG_RELEASE=1
PKG_LICENSE:=MIT

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://pypi.python.org/packages/84/ce/7ea5396efad1cef682bbc4068e72a0276341d9d9d0f501da609fab9fcb80/
PKG_MD5SUM:=338e5e8a83ea0f0625f768dba4597530
PKG_BUILD_DEPENDS:=python python-setuptools

include $(INCLUDE_DIR)/package.mk
$(call include_mk, python-package.mk)

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
