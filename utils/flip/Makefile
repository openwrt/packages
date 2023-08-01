#
# Copyright (C) 2023 Kai Tetzlaff
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=flip
PKG_VERSION:=1.20
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)_$(PKG_VERSION).orig.tar.gz
PKG_SOURCE_URL:=@DEBIAN/pool/main/f/flip
PKG_HASH:=4cd45e581c71d7bcf1ab824a47fb9263fe5371ce702879a7d2efa08d27253471

PKG_MAINTAINER:=Kai Tetzlaff <openwrt@tetzco.de>
PKG_LICENSE:=GPL-2.0-or-later

PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/flip
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=convert text file line endings between Unix and DOS formats
  URL:=http://packages.debian.org/flip
endef

define Package/flip/description
  The program converts line endings of text files between MS-DOS and
  *nix formats. It detects binary files in a nearly foolproof way and
  leaves them alone unless you override this. It will also leave files
  alone that are already in the right format and preserves file
  timestamps. User interrupts are handled gracefully and no garbage or
  corrupted files left behind.

  The program does not convert files to a different character set, and
  it can not handle old Apple Macintosh line endings that use CR only.
endef

EXTRA_CPPFLAGS += -DBSD -DIX -DSTDINCLUDE

define Package/flip/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/flip $(1)/usr/bin/
	$(LN) flip $(1)/usr/bin/toix
	$(LN) flip $(1)/usr/bin/toms
endef

$(eval $(call BuildPackage,flip))
