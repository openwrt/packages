#
# Copyright (C) 2022 Julien Malik <julien.malik@paraiso.me>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

# initial implementation kindly stolen from (and then updated) :
# https://forum.openwrt.org/t/xxhash-makefile/118426

include $(TOPDIR)/rules.mk

PKG_NAME:=xxhash
PKG_VERSION:=0.8.2
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)_$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/Cyan4973/xxHash/archive/v$(PKG_VERSION)
PKG_HASH:=baee0c6afd4f03165de7a4e67988d16f0f2b257b51d0e3cb91909302a26a79c4

# The source for the library (xxhash.c and xxhash.h) is BSD
# The source for the command line tool (xxhsum.c) is GPLv2+
PKG_LICENSE:=BSD-2-Clause GPL-2.0-or-later
PKG_LICENSE_FILES:=LICENSE cli/COPYING
PKG_MAINTAINER:=Julien Malik <julien.malik@paraiso.me>

PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

PKG_UNPACK:=$(HOST_TAR) -C "$(PKG_BUILD_DIR)" --strip-components=1 -xzf "$(DL_DIR)/$(PKG_SOURCE)"

define Package/xxhash/Default
  TITLE:=Extremely fast hash algorithm
  URL:=https://xxhash.com/
endef

define Package/xxhash/Default/description
  xxHash is an Extremely fast Hash algorithm, running at RAM speed
  limits. It successfully completes the SMHasher test suite which
  evaluates collision, dispersion and randomness qualities of hash
  functions. Code is highly portable, and hashes are identical on all
  platforms (little / big endian).
endef

define Package/libxxhash
  $(call Package/xxhash/Default)
  SECTION:=libs
  CATEGORY:=Libraries
endef

define Package/libxxhash/description
  $(call Package/xxhash/Default/description)

  This package contains the shared library.
endef

define Package/xxhash
  $(call Package/xxhash/Default)
  SECTION:=utils
  CATEGORY:=Utilities
  DEPENDS:= +libxxhash
endef

define Package/xxhash/description
  $(call Package/xxhash/Default/description)

  This package contains the executables.
endef

MAKE_FLAGS += PREFIX=/usr

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/*.h $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libxxhash.{a,so*} $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/libxxhash.pc $(1)/usr/lib/pkgconfig/
endef

define Package/libxxhash/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libxxhash.so.* $(1)/usr/lib/
endef

define Package/xxhash/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/xxh*sum $(1)/usr/bin/
endef

$(eval $(call BuildPackage,libxxhash))
$(eval $(call BuildPackage,xxhash))
