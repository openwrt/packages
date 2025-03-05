#
# Copyright (C) 2023 Jeffery To
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=mpc
PKG_VERSION:=1.3.1
PKG_RELEASE:=1

PKG_SOURCE_URL:=@GNU/mpc/
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_HASH:=ab642492f5cf882b74aa0cb730cd410a81edcdbec895183ce930e706c1c759b8

PKG_LICENSE:=LGPL-3.0-or-later
PKG_LICENSE_FILES:=COPYING.LESSER
PKG_MAINTAINER:=Jeffery To <jeffery.to@gmail.com>

PKG_BUILD_PARALLEL:=1
PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/libmpc
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=GNU MPC library
  URL:=https://www.multiprecision.org/mpc/
  DEPENDS:=+libgmp +libmpfr
  ABI_VERSION:=3
endef

define Package/libmpc/description
GNU MPC is a portable library written in C for arbitrary precision
arithmetic on complex numbers providing correct rounding. It implements
a multiprecision equivalent of the C99 standard. It builds upon the GNU
MP and the GNU MPFR libraries.
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/mpc* $(1)/usr/include/

	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libmpc.{a,so*} $(1)/usr/lib/
endef

define Package/libmpc/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libmpc.so.* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libmpc))
