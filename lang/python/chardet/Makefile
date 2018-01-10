#
# Copyright (C) 2007-2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=chardet
PKG_VERSION:=3.0.4
PKG_RELEASE:=1
PKG_LICENSE:=LGPL-2.1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://pypi.python.org/packages/fc/bb/a5768c230f9ddb03acc9ef3f0d4a3cf93462473795d18e9535498c8f929d/
PKG_HASH:=84ab92ed1c4d4f16916e05906b6b75a6c0fb5db821cc65e70cbd64a3e2a5eaae

include $(INCLUDE_DIR)/package.mk
include ../python-package.mk

define Package/chardet
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  MAINTAINER:=Gergely Kiss <mail.gery@gmail.com>
  TITLE:=Universal encoding detector for Python 2 and 3
  URL:=https://github.com/chardet/chardet
  DEPENDS:=+python
endef

define Package/chardet/description
  Universal encoding detector for Python 2 and 3
endef

define Build/Compile
	$(call Build/Compile/PyMod,,install --prefix=/usr --root=$(PKG_INSTALL_DIR))
endef

define Package/chardet/install
	$(INSTALL_DIR) $(1)$(PYTHON_PKG_DIR)
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) \
	    $(PKG_INSTALL_DIR)$(PYTHON_PKG_DIR)/* \
	    $(1)$(PYTHON_PKG_DIR)
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/chardetect \
	    $(1)/usr/bin
	# fix python exec path in scripts
	sed -i 's/#!.*/#!\/usr\/bin\/python/g' $(1)/usr/bin/chardetect
endef

$(eval $(call BuildPackage,chardet))
