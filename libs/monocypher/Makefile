#
# Copyright (C) 2026 Daniel Golle <daniel@makrotopia.org>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=monocypher
PKG_VERSION:=4.0.3
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://monocypher.org/download
PKG_HASH:=8cc9bc341a66249016db9bd70e9142d8d0aef9945973744b1ac05dbc55d8ee66

PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>
PKG_LICENSE:=BSD-2-Clause OR CC0-1.0
PKG_LICENSE_FILES:=LICENCE.md

PKG_BUILD_FLAGS:=gc-sections
PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/libmonocypher
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Small, auditable, portable cryptographic library
  URL:=https://monocypher.org/
  ABI_VERSION:=4
endef

define Package/libmonocypher/description
  Monocypher is a small, portable, easy to use cryptographic library in
  about 2000 lines of C99. It provides authenticated encryption
  (XChaCha20-Poly1305), hashing (BLAKE2b, SHA-512), password hashing
  (Argon2), key exchange (X25519), signatures (EdDSA with BLAKE2b, and
  Ed25519 proper) and Elligator 2 hidden key encoding.
endef

MAKE_FLAGS += \
	PREFIX=/usr

# The stock "install" target also runs install-doc, which drags in the man
# pages we do not ship on the target.
define Build/Install
	$(call Build/Install/Default,install-lib install-pc)
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/monocypher.h $(1)/usr/include/
	$(CP) $(PKG_INSTALL_DIR)/usr/include/monocypher-ed25519.h $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libmonocypher.so* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/monocypher.pc $(1)/usr/lib/pkgconfig/
endef

define Package/libmonocypher/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libmonocypher.so.* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libmonocypher))
