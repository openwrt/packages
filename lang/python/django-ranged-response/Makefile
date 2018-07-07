#
# Copyright (C) 2007-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=django-ranged-response
PKG_VERSION:=0.2.0
PKG_RELEASE:=1
PKG_LICENSE:=MIT

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/70/e3/9372fcdca8e9c3205e7979528ccd1a14354a9a24d38efff11c1846ff8bf1
PKG_HASH:=f71fff352a37316b9bead717fc76e4ddd6c9b99c4680cdf4783b9755af1cf985

include $(INCLUDE_DIR)/package.mk
include ../python-package.mk

define Package/django-ranged-response
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  MAINTAINER:=Eneas U de Queiroz <cote2004-github@yahoo.com>
  TITLE:=Modified Django FileResponse that adds Content-Range headers.
  URL:=https://github.com/wearespindle/django-ranged-fileresponse
  DEPENDS:=+python +django
endef

define Package/django-ranged-response/description
  Modified Django FileResponse that adds Content-Range headers.
endef

define Build/Compile
	$(call Build/Compile/PyMod,,install --prefix=/usr --root=$(PKG_INSTALL_DIR))
endef

define Package/django-ranged-response/install
	$(INSTALL_DIR) $(1)$(PYTHON_PKG_DIR)
	$(CP) \
	    $(PKG_INSTALL_DIR)$(PYTHON_PKG_DIR)/* \
	    $(1)$(PYTHON_PKG_DIR)
endef

$(eval $(call BuildPackage,django-ranged-response))
