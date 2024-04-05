# SPDX-Identifier-License: GPL-3.0-or-later
#
# Copyright (C) 2022-2024 源 文雨 <fumiama@foxmail.com>

include $(TOPDIR)/rules.mk

PKG_NAME:=base16384
PKG_VERSION:=2.3.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/fumiama/base16384/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=b3cda811eabd002cc16f5c0a3fdcac7bf4ffbdeb1447139e6fd21de4811e2f76

PKG_MAINTAINER:=源 文雨 <fumiama@foxmail.com>
PKG_LICENSE:=GPL-3.0-or-later
PKG_LICENSE_FILES:=LICENSE

CMAKE_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/base16384
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Encode binary files to printable utf16be
  URL:=https://github.com/fumiama/base16384
endef

define Package/libbase16384
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Base16384 library
  URL:=https://github.com/fumiama/base16384
endef

define Package/base16384/description
  There are 16384 Chinese characters (from \u4E00 to \u8DFF)
  as the "alphabet", just like what base64 did.
  If length of the data has a remainder after mod 7,
  an unicode Chinese character \u3Dxx will be appended to present it
  with xx ranging from 01 to 06.
endef

define Package/libbase16384/description
	$(call Package/base16384/description)
endef

define Package/base16384/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/base16384 $(1)/usr/bin/base16384
endef

define Package/libbase16384/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libbase16384.so.* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,base16384))
$(eval $(call BuildPackage,libbase16384))
