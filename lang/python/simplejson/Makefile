#
# Copyright (C) 2007-2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=simplejson
PKG_VERSION:=3.16.0
PKG_RELEASE:=1
PKG_LICENSE:=MIT

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/source/s/simplejson
PKG_HASH:=b1f329139ba647a9548aa05fb95d046b4a677643070dc2afc05fa2e975d09ca5

include $(INCLUDE_DIR)/package.mk
include ../python-package.mk

define Package/simplejson
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  MAINTAINER:=Gergely Kiss <mail.gery@gmail.com>
  TITLE:=Simple, fast, extensible JSON encoder/decoder for Python
  URL:=https://simplejson.readthedocs.org/
  DEPENDS:=+python
endef

define Package/simplejson/description
  Simple, fast, extensible JSON encoder/decoder for Python
endef

define Build/Compile
	$(call Build/Compile/PyMod,,install --prefix=/usr --root=$(PKG_INSTALL_DIR))
endef

define Package/simplejson/install
	$(INSTALL_DIR) $(1)$(PYTHON_PKG_DIR)
	$(CP) \
	    $(PKG_INSTALL_DIR)$(PYTHON_PKG_DIR)/* \
	    $(1)$(PYTHON_PKG_DIR)
endef

$(eval $(call BuildPackage,simplejson))
