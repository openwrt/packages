#
# Copyright (C) 2007-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-qrcode
PKG_VERSION:=6.0
PKG_RELEASE:=1
PKG_LICENSE:=BSD-3-Clause

PKG_SOURCE:=qrcode-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/8d/b6/beed3d50e1047a2aa6437d3a653e5f31feb7f4de8bc054299dc205682e41
PKG_HASH:=037b0db4c93f44586e37f84c3da3f763874fcac85b2974a69a98e399ac78e1bf
PKG_BUILD_DIR:=$(BUILD_DIR)/qrcode-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include ../python-package.mk

define Package/python-qrcode
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  MAINTAINER:=Eneas U de Queiroz <cote2004-github@yahoo.com>
  TITLE:=QR Code image generator
  URL:=https://github.com/lincolnloop/python-qrcode
  DEPENDS:=+python +python-six
endef

define Package/python-qrcode/description
  Pure python QR Code generator
endef

define Build/Compile
	$(call Build/Compile/PyMod,,install --prefix=/usr --root=$(PKG_INSTALL_DIR))
endef

define Package/python-qrcode/install
	$(INSTALL_DIR) $(1)$(PYTHON_PKG_DIR)
	$(CP) \
	    $(PKG_INSTALL_DIR)$(PYTHON_PKG_DIR)/* \
	    $(1)$(PYTHON_PKG_DIR)
endef

$(eval $(call BuildPackage,python-qrcode))
