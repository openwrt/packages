#
# Copyright (C) 2016 Nikil Mehta <nikil.mehta@gmail.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=uudeview
PKG_VERSION:=0.5.20
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://www.fpx.de/fp/Software/UUDeview/download/
PKG_MD5SUM:=e49a510ddf272022af204e96605bd454bb53da0b3fe0be437115768710dae435

PKG_MAINTAINER:=Nikil Mehta <nikil.mehta@gmail.com>
PKG_LICENSE:=GPL-2.0
PKG_LICENSE_FILES:=COPYING

include $(INCLUDE_DIR)/package.mk

define Package/libuu
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Library for decoding/encoding several popular file encodings
  URL:=http://www.fpx.de/fp/Software/UUDeview/
endef

define Package/uudeview
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Smart multi-file multi-part decoder (command line)
  URL:=http://www.fpx.de/fp/Software/UUDeview/
  DEPENDS:=+libuu
endef

define Package/libuu/description
	Libuu is a library of functions for decoding and encoding files in
	the following formats: uuencode, xxencode, BASE64, quoted printable,
	and BinHex.
endef

define Package/uudeview/description
	This is a command-line decoder and encoder for files encoded with the
	following formats: uuencode, xxencode, BASE64, quoted printable, and
	BinHex.
	.
	This package used to contain an X11-based GUI decoder called xdeview.
	That program is now in the xdeview package.
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/uulib/libuu.so* $(1)/usr/lib
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_BUILD_DIR)/uulib/{fptools.h,uudeview.h,uuint.h} $(1)/usr/include
endef

define Package/libuu/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/uulib/libuu.so* $(1)/usr/lib
endef

define Package/uudeview/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/unix/{uuenview,uudeview} $(1)/usr/bin/
endef

$(eval $(call BuildPackage,libuu))
$(eval $(call BuildPackage,uudeview))
