#
# Copyright (C) 2023 Jeffery To
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=mpc
PKG_VERSION:=1.4.1
PKG_RELEASE:=1

PKG_SOURCE_URL:=@GNU/mpc/
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_HASH:=91204cd32f164bd3b7c992d4a6a8ce6519511aadab30f78b6982d0bf8d73e931

PKG_LICENSE:=LGPL-3.0-or-later
PKG_LICENSE_FILES:=COPYING.LESSER
PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>

PKG_BUILD_PARALLEL:=1
PKG_FIXUP:=autoreconf
PKG_INSTALL:=1
# Build/install only the library; skip the tests, doc and tools subdirs.
PKG_SUBDIRS:=src

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
