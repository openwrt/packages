#
# Copyright (C) 2007-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-qrcode
PKG_VERSION:=6.1
PKG_RELEASE:=1
PKG_LICENSE:=BSD-3-Clause

PKG_SOURCE:=qrcode-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/source/q/qrcode/
PKG_HASH:=505253854f607f2abf4d16092c61d4e9d511a3b4392e60bff957a68592b04369
PKG_BUILD_DIR:=$(BUILD_DIR)/$(BUILD_VARIANT)-oauthlib-$(PKG_VERSION)
PKG_UNPACK=$(HOST_TAR) -C $(PKG_BUILD_DIR) --strip-components=1 -xzf $(DL_DIR)/$(PKG_SOURCE)

include $(INCLUDE_DIR)/package.mk
include ../python-package.mk

define Package/python-qrcode
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  MAINTAINER:=Eneas U de Queiroz <cote2004-github@yahoo.com>
  TITLE:=QR Code image generator
  URL:=https://github.com/lincolnloop/python-qrcode
  DEPENDS:=+python +python-six +python-setuptools +pillow
  VARIANT:=python
endef

define Package/python-qrcode/description
  Pure python QR Code generator
endef

$(eval $(call PyPackage,python-qrcode))
$(eval $(call BuildPackage,python-qrcode))
$(eval $(call BuildPackage,python-qrcode-src))
