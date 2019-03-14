#
# Copyright (C) 2007-2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=gunicorn
PKG_VERSION:=19.9.0
PKG_RELEASE=2
PKG_LICENSE:=MIT

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/source/g/gunicorn
PKG_HASH:=fa2662097c66f920f53f70621c6c58ca4a3c4d3434205e608e121b5b3b71f4f3
PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>

include $(INCLUDE_DIR)/package.mk
include ../python-package.mk

define Package/gunicorn
    SUBMENU:=Python
    SECTION:=lang
    CATEGORY:=Languages
    TITLE:=WSGI HTTP Server for UNIX
    URL:=https://gunicorn.org
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
