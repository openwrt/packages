#
# Copyright (C) 2017 Daniel Engberg <daniel.engberg.lists@pyret.net>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=telnet-bsd
PKG_VERSION=1.2
PKG_RELEASE:=1
PKG_MAINTAINER:=Paul Spooren <mail@aparcar.org>
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=COPYING

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=https://dev.gentoo.org/~mschiff/distfiles/
PKG_SOURCE_SUBDIR=$(PKG_NAME)-$(PKG_VERSION)
PKG_HASH:=d6a9d26740ef75565cb1ed8ff11e327d240e6734748b2d1d2e96c126849e4733

PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk

TARGET_CFLAGS+= -Wno-format-security

define Package/telnet-bsd
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+libncurses
  TITLE:=telnet-bsd
  URL:=https://www.openbsd.org/
endef

define Package/telnet-bsd/description
  Telnet client ported from OpenBSD
endef

define Package/telnet-bsd/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/telnet/telnet $(1)/usr/bin/
endef

$(eval $(call BuildPackage,telnet-bsd))
